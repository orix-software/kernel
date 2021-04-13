#!/usr/bin/python3



# from pprint import pprint

import stat    # for file properties
import os      # for filesystem modes (O_RDONLY, etc)
import errno   # for error number codes (ENOENT, etc)
               # - note: these must be returned as negatives
import sys

import argparse

__version__ = '0.1'

# pprint(args)


def ReadHeader(ftap):
	Header = {}

	b = ftap.read(1)
	if b == chr(0x16):
		while b == chr(0x16):
			b = ftap.read(1)

		if b == chr(0x24):
			flag0 = ftap.read(2)
			fType = ord(ftap.read(1))
			fStatus = ord(ftap.read(1))
			fileEndAdr = ord(ftap.read(1))*256 + ord(ftap.read(1))
			fileStartAdr = ord(ftap.read(1))*256 + ord(ftap.read(1))
			b = ftap.read(1)

			fileName = ''
			b = ftap.read(1)
			while b != chr(0):
				fileName = fileName + b
				b =ftap.read(1)
			Header['flag0']	= flag0
			Header['type']	= fType
			Header['status']= fStatus
			Header['start']	= fileStartAdr
			Header['end']	= fileEndAdr
			Header['name']	= fileName
			Header['size']	= Header['end']-Header['start']

			return Header

	elif b == chr(0x01):
		b = ftap.read(1)
		b = ftap.read(3)
		if b == 'ori':
			b = ftap.read(1)
			cpu = ord(ftap.read(1))
			ostype = ord(ftap.read(1))
			b = ftap.read(5)
			fType = ord(ftap.read(1))
			fileStartAdr = ord(ftap.read(1))*256 + ord(ftap.read(1))
			fileEndAdr = ord(ftap.read(1))*256 + ord(ftap.read(1))
			fileExecAdr = ord(ftap.read(1))*256 + ord(ftap.read(1))

			Header['os'] = ostype
			Header['cpu'] = cpu
			Header['type'] = fType
			Header['start'] = fileStartAdr
			Header['end'] = fileEndAdr
			Header['exec'] = fileExecAdr
			Header['size']	= Header['end']-Header['start']

			return Header


	Header['type'] = 'raw'
	ftap.seek(0,2)
	Header['size'] = ftap.tell()
	ftap.seek(0,0)

	# return False
	return Header

def diff(file1, file2, output, color):
	i = 0
	s1 = ""
	s2 = ""
	with open(file1,"rb") as f1:
		# On saute l'entete .tap
		Header1 = ReadHeader(f1)
		if not Header1:
			print("Fichier %s incorrect" % f1.name)
			exit(1)

		with open(file2,"rb") as f2:
			# On saute l'entete .tap
			Header2 = ReadHeader(f2)
			if not Header2:
				print("Fichier %s incorrect" % f2.name)
				exit(1)

			if Header1['type'] != Header2['type']:
				print("Fichiers de type differents (%s:%#02X, %s:%#02X)" % (f1.name,Header1['type'], f2.name, Header2['type']))
				exit(1)

			if Header1['size'] != Header2['size']:
				print("Fichiers de tailles differentes (%s:%d, %s:%d)" % (f1.name,Header1['size'], f2.name, Header2['size']))
				exit(1)

			print('    |    M A P    |%-24s|%-24s' % (f1.name, f2.name))
			print('____|_____________|________________________|________________________')
			o = 0
			n = 0
			map = ""
			while i< Header1['size']:
				c1=f1.read(1)
				c2=f2.read(1)

				if not color:
					s1 = s1 + "%02x " % ord(c1)
					s2 = s2 + "%02x " % ord(c2)

				if c1 != c2:
					o += 2**(7-i%8)
					# Ordre inverse a cause de la boucle
					# lda($00),x avec x=7 -> 0
					#o += 2**(i%8)

					n += 1
					map += '*'
					# 'print('*',end="")

					if color:
						# s1 = s1 + "%c[1;47;31m%02x%c[0;30m " % (27, ord(c1), 27)
						# s2 = s2 + "%c[1;47;31m%02x%c[0;30m " % (27, ord(c2), 27)
						s1 = s1 + "%c[1;47;31m%02x%c[0;38m " % (27, ord(c1), 27)
						s2 = s2 + "%c[1;47;31m%02x%c[0;38m " % (27, ord(c2), 27)

				else:
					map += '.'
					# print('.',end="")

					if color:
						s1 = s1 + "%02x " % ord(c1)
						s2 = s2 + "%02x " % ord(c2)

				i += 1
				if i % 8 == 0:
					if output is not None:
						output.write(bytes([o]))

					print("%04X| %s %02X |%s|%s" % (i-8,map,o,s1,s2))
					s1 = ""
					s2 = ""
					map = ""
					o = 0

			if s1!= '':
				if color:
					# Ajustement necessaire a cause des \e[xxm
					s1 += '%*s' % ((8-(i%8))*3, ' ')

				# print("%*s %02X |%-24s|%-24s" % (8-(i%8), ' ',o,s1,s2))
				print("%04X| %s%*s %02X |%-24s|%-24s" % (i-(i%8),map, 8-(i%8), ' ',o,s1,s2))

			print('____|_____________|________________________|________________________')
			print('                      Size         %6d' % i)
			print('                      Differences  %6d' % n)
			print('____________________________________________________________________')

		f2.close()
	f1.close()


def main():
	parser = argparse.ArgumentParser(prog='diff2map', description='Create diff map file', formatter_class=argparse.ArgumentDefaultsHelpFormatter)

	parser.add_argument('file', type=str, nargs='+', metavar='file', help='filename to diff')
	# parser.add_argument('--output', '-o', type=argparse.FileType('wb'), default=sys.stdout, help='MAP filename')
	parser.add_argument('--output', '-o', type=argparse.FileType('wb'), default=None, help='MAP filename')
	parser.add_argument('--color', '-c', default=False, action='store_true', help='Color output')
	parser.add_argument('--version', '-v', action='version', version= '%%(prog)s v%s' % __version__)

	args = parser.parse_args()

	if len(args.file) != 2:
		parser.print_help()
		exit(1)

	diff(args.file[0], args.file[1], args.output, args.color)


if __name__ == '__main__':
	main()
