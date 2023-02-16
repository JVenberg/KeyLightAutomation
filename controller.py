import click
import requests


@click.command()
@click.option("--ip", "-i", required=True, help="The External IP of the Key Light(s).")
@click.option(
    "--port",
    "-p",
    multiple=True,
    help="The Port(s) of each Key Light.",
)
@click.option("--on", "-o", is_flag=True, help="Turn on the Key Light(s).")
def main(ip, port, on):
    print(f"Turning *{'on' if on else 'off'}* following lights: {', '.join(f'{ip}:{p}' for p in port)}")
    for p in port:
        r = requests.put(
            f"http://{ip}:{p}/elgato/lights", json={"lights": [{"on": on}]},
            timeout=5
        )
        print(f"Port: {p}, Light: {on}, Response Code: {r.status_code}")


if __name__ == "__main__":
    main(auto_envvar_prefix="KLIGHT")
