# https://diagrams.mingrammer.com/docs/nodes/aws

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import Route53, ELB
from diagrams.onprem.network import Consul, Traefik
from diagrams.onprem.compute import Nomad

outformat="png"

graph_attr = {
    "layout":"dot",
    "compound":"true",
    "splines":"spline",
    "bgcolor": "white",
    "fontsize": "45",
    }

with Diagram("nomad architecture", filename="diagram", direction="TB",outformat=outformat, graph_attr=graph_attr):
    with Cluster("CLOUD aws"):
        with Cluster("NOMAD REGION global"):
            with Cluster("SERVERS"):
                consul1_global = Consul("consul")
                nomad1_global = Nomad("nomad")
            with Cluster("NOMAD DATACENTER dc1"):
                with Cluster("ASG client"):
                    client1 = Nomad("client")
                    nomad1_global - Edge(penwidth = "4", lhead = "cluster_NOMAD DATACENTER dc1", ltail="cluster_SERVERS", minlen="2") - client1
                    consul1_global - Edge(penwidth = "4", lhead = "cluster_NOMAD DATACENTER dc1", ltail="cluster_SERVERS", minlen="2") - client1
with Diagram("ingress", filename="ingress", direction="TB",outformat=outformat, graph_attr=graph_attr):
    dns = Route53("dns")
    with Cluster("NOMAD REGION global"):
        with Cluster("SUBNET public"):
            lb_app = ELB("LB app")
            lb_servers = ELB("LB servers")
        with Cluster("SUBNET private"):
            with Cluster("SERVERS"):
                consul1_global = Consul("consul")
                nomad1_global = Nomad("nomad")
            with Cluster("NOMAD DATACENTER dc1"):
                client1 = Nomad("client")
                dns >> Edge(lhead="cluster_SUBNET public", color="blue") >> [lb_app, lb_servers]
                lb_app >> Edge(ltail="cluster_SUBNET public", lhead="cluster_NOMAD DATACENTER dc1", minlen="2", color="blue") >> client1
                lb_servers >> Edge(ltail="cluster_SUBNET public", lhead="cluster_SERVERS", minlen="1", color="blue") >> [consul1_global, nomad1_global]