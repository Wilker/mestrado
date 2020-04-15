from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink, Intf
from subprocess import call

def myNetwork():

    net = Mininet( topo=None,
                   build=False,
                   ipBase='192.168.3.0/24')

    info( '*** Adding controllers\n' )
    c1=net.addController(name='c1',
                      controller=RemoteController,
                      ip='192.168.2.11',
                      protocol='tcp',
                      port=6653)
  
    c2=net.addController(name='c2',
                      controller=RemoteController,
                      ip='192.168.2.12',
                      protocol='tcp',
                      port=6653)
  
    info( '*** Add switches\n')
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch)
    s2 = net.addSwitch('s2', cls=OVSKernelSwitch)
    s3 = net.addSwitch('s3', cls=OVSKernelSwitch)
    s4 = net.addSwitch('s4', cls=OVSKernelSwitch)

    info( '*** Add hosts\n')
    h1 = net.addHost('h1', cls=Host, ip='192.168.3.11', defaultRoute=None)
    h2 = net.addHost('h2', cls=Host, ip='192.168.3.12', defaultRoute=None)

    info( '*** Add links\n')
    net.addLink(h1, s1)
    net.addLink(h2, s4)

    net.addLink(s1, s2)
    net.addLink(s1, s3)

    net.addLink(s2, s4)
    net.addLink(s3, s4)
    
    info( '*** Starting network\n')
    net.build()
    info( '*** Starting controllers\n')
    for controller in net.controllers:
        info(controller)
        controller.start()

    info( '*** Starting switches\n')
    net.get('s1').start([c1,c2])
    net.get('s2').start([c1,c2])
    net.get('s3').start([c1,c2])
    net.get('s4').start([c1,c2])


    info( '*** Post configure switches and hosts\n')

    pingall()
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()