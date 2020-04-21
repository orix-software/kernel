#!/usr/bin/python
# -*- coding: utf8 -*-

from __future__ import print_function

from pprint import pprint

import fileinput


var_types = {
    '.addr': 'unsigned int',
    '.byte': 'char',
    '.word': 'int',
    '.dword': 'double',
    '.res': 'char'
    }

def_bloc = False
def_cbloc = False
def_struct = False
struct_name = ''
def_proc = False
proc_name = ''

last_label = ''

for line in fileinput.input():

    line = line.rstrip()

    #if fileinput.isfirstline():
    #    fname = fileinput.filename()
    #    print('\n'.join(['/**', ' * @file '+fname, '*/']))

    if line:
        inst = line.split()
        nb_inst = len(inst)

        line_out = ''

        # pprint(inst)

        if def_bloc:
            if inst[0] == ';;':
                def_bloc = False
                line_out = '*/'

            else:
                line_out = line[1:]

                # Au cas où il manque un ' ' entre le ';' et le commentaire
                #if len(inst[0]) > 1 and inst[0][1] == ';':
                #    line_out += inst[0][1:]
                #    print('----', line)

                #if nb_inst > 1:
                #    line_out += ' '.join(inst[1:])

        elif def_cbloc:
            line_out = line

            if inst[0] == '*/':
                def_cbloc = False

        elif def_proc:
            if inst[0] == '.endproc':
                def_proc = False

                proc_name = ''
                line_out = '};'

            else:
                # On ne prend rien en compte dans la fonction
                # TODO: Ajouter la prise en charge des variables et les déclarer privées?
                line_out = ''

        elif def_struct:
            if inst[0] == '.endstruct':
                def_struct = False

                line_out = '} '+struct_name+';'

            else:
                # Traitement des membres de la structure
                if nb_inst >= 2 and inst[1] in ['.byte', '.byt', '.word', '.addr', '.dword', '.res']:
                    cmnt = ''

                    if inst[1] in ['.byte', '.byt']:
                        line_out = var_types['.byte']+' '+inst[0]+';'

                        if nb_inst > 3:
                            cmnt = ' '.join(inst[3:])

                    elif inst[1] == '.word':
                        line_out = var_types['.word']+' '+inst[0]+';'

                        if nb_inst > 3:
                            cmnt = ' '.join(inst[3:])

                    elif inst[1] == '.addr':
                        line_out = var_types['.addr']+' '+inst[0]+';'

                        if nb_inst > 3:
                            cmnt = ' '.join(inst[3:])

                    elif inst[1] == '.dword':
                        line_out = var_types['.dword']+' '+inst[0]+';'

                        if nb_inst > 3:
                            cmnt = ' '.join(inst[3:])

                    elif inst[1] == '.res':
                        # Vérifier  si inst[3] == ';' au cas où?

                        line_out = var_types['.res']+' %s[%s];' % (inst[0], inst[2])

                        if nb_inst > 4:
                            cmnt = ' '.join(inst[4:])

                    else:
                        line_out = ''

                    if line_out and cmnt:
                        line_out = '/** '+cmnt+' */ '+line_out

        else:
            if inst[0] == ';;':
                def_bloc = True

                line_out = '/** '
                if nb_inst >=2:
                    if inst[1] == '/**':
                        inst[1] = ''

                    line_out += ' '.join(inst[1:])

            elif inst[0] in ['/*', '/**']:
                def_cbloc = True
                line_out = line

            elif inst[0] == '.proc':
                def_proc = True

                # Ne prend pas en compte un éventuel commentaire sur la ligne .proc
                # TODO: Ajouter un @brief pour le prendre en compte?
                proc_name = inst[1]

                line_out = proc_name + '() {'

            elif inst[0] == '.struct':
                def_struct = True

                # Ne prend pas en compte un éventuel commentaire sur la ligne .proc
                # TODO: Ajouter un @brief pour le prendre en compte?
                struct_name = inst[1]

                line_out = 'typedef struct {'


            elif inst[0] == '.define':
                # ATTENTION: un commentaire à la fin de la ligne peut poser problème
                if nb_inst > 3 and inst[3] == ';':
                    line_out = '/** ' + ' '.join(inst[4:]) + ' */ '
                    line_out += '#define ' + inst[1] + ' ' + inst[2]

                else:
                    line_out = '#define ' + inst[1] + ' '.join(inst[2:])

            elif inst[0] == '.include':
                # Pas de prise en compte d'un éventuel commentaire en fin de ligne
                # TODO: A prende en compte?
                line_out = '#include '+inst[1]

            elif inst[0] == '.tag':
                line_out = '%s %s;' % (inst[1], last_label)

            elif inst[0] == '.import':
                line_out = 'extern ' + inst[1] +';'

            # Déclaration d'une zone mémoire
            elif last_label and inst[0] in ['.byte', '.byt', '.word', '.addr', '.dword', '.res']:
                if inst[0] in ['.byte', '.byt']:

                    line_out = var_types['.byte']+' '+last_label

                    var_len = inst[1].count(',')+1
                    if var_len > 1:
                        line_out += '[%d]' % var_len

                    line_out += ';'

                elif inst[0] == '.word':
                    line_out = var_types['.word']+' '+last_label

                    var_len = inst[1].count(',')+1
                    if var_len > 1:
                        line_out += '[%d]' % var_len

                    line_out += ';'

                elif inst[0] == '.addr':
                    line_out = var_types['.addr']+' '+last_label

                    var_len = inst[1].count(',')+1
                    if var_len > 1:
                        line_out += '[%d]' % var_len

                    line_out += ';'

                elif inst[0] == '.dword':
                    line_out = var_types['.dword']+' '+last_label

                    var_len = inst[1].count(',')+1
                    if var_len > 1:
                        line_out += '[%d]' % var_len

                    line_out += ';'

                elif inst[0] == '.res':
                    line_out = var_types['.res']+' %s[%s];' % (last_label, ' '.join(inst[1:]))

                else:
                    line_out = ''

                last_label = ''

            elif nb_inst == 1:
                # Label?
                # Pas d'espace avant un label
                if not line[0] in [' ', '.', ';', '@']:
                    if inst[0][-1] == ':':
                        last_label = inst[0][:-1]
                        line_out = ''

                    else:
                        last_label = inst[0]
                        line_out = ''


            elif nb_inst >= 3:
                # Déclaration d'une variable / label
                if inst[1] == '=':
                    if nb_inst > 3 and inst[3] == ';':
                        line_out = '/** ' + ' '.join(inst[4:]) + ' */ '
                        line_out += '#define ' + inst[0] + ' ' + inst[2]

                    else:
                        line_out = '#define '+inst[0] + ' ' + ' '.join(inst[2:])

                elif inst[1] == ':=':
                    if nb_inst > 3 and inst[3] == ';':
                        line_out = '/** ' + ' '.join(inst[4:]) + ' */ '
                        line_out += '#define ' + inst[0] + ' ' + inst[2]

                    else:
                        line_out = '#define '+inst[0] + ' ' + ' '.join(inst[2:])

                else:
                    line_out = ''

            else:
                # line_out = '????: '+line
                if line[0] !=';':
                    last_label = ''
                line_out = ''


        print(line_out)

    else:
        print('')

fname = fileinput.filename()
print('\n'.join(['/**', ' * @file '+fname, '*/']))
