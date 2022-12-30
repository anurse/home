job "grafana" {
    datacenters = ["home0"]

    group "grafana" {
        network {
            port "http" {
                to = "3000"
            }
        }
        service {
            name = "grafana"
            port = "http"
            tags = [
                "traefik",
                "traefik.enable=true",
                "traefik.http.routers.grafana.rule=Host(`home.analogrelay.net`) && PathPrefix(`/grafana`)",
                "traefik.http.routers.grafana.entrypoints=http",
            ]
        }

        volume "grafana-data" {
            type = "host"
            read_only = false
            source = "grafana"
        }

        task "grafana" {
            driver = "docker"
            config {
                image = "grafana/grafana:9.3.2"
                ports = ["http"]
                volumes = [
                    "local/grafana.ini:/etc/grafana/grafana.ini"
                ]
            }

            volume_mount {
                volume = "grafana-data"
                destination = "/var/lib/grafana"
                read_only = false
            }

            template {
                data = <<EOH
[server]
domain = home.analogrelay.net
root_url = $(protocol)s://%(domain)s:%(http_port)s/grafana/
serve_from_sub_path = true
EOH
                destination = "local/grafana.ini"
            }
        }
    }
}