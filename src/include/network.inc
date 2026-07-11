.define KERNEL_STUB1_NETWORK             $01
.define KERNEL_STUB2_NETWORK             $02
.define KERNEL_STUB3_NETWORK             $03
.define KERNEL_START_NETWORK             $04

.define KERNEL_SOCKET_NETWORK            $05
.define KERNEL_BIND_NETWORK              $06
.define KERNEL_CONNECT_NETWORK           $07
.define KERNEL_RECV_NETWORK              $08
.define KERNEL_SEND_NETWORK                       $09
.define KERNEL_SOCKET_CLOSE_NETWORK               $0A
.define KERNEL_SOCKET_CLOSE_FROM_PID_NETWORK      $0B


.define KERNEL_NETWORK_STATE_NOT_INITIALIZED  $00
.define KERNEL_NETWORK_STATE_CHIP_INITIALIZED $01
.define KERNEL_NETWORK_CABLE_DISCONNECTED     $02
.define KERNEL_NETWORK_CABLE_CONNECTED        $03
.define KERNEL_NETWORK_FULLY_STARTED          $04
.define KERNEL_NETWORK_STARTING_DHCP          $05

.define KERNEL_NETWORK_STATE_CHIP_NOT_FOUND   $FF

; When network stack is initialized, this value will be the first source port for an openning socket
.define KERNEL_FIRST_SOURCE_PORT_INIT         140