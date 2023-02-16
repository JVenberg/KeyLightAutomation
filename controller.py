import click
import requests


@click.command()
@click.option("--ip", "-i", prompt="IP", help="The External IP of the Key Light(s).")
@click.option(
    "--port",
    "-p",
    multiple=True,
    prompt="Port(s)",
    help="The Port(s) of each Key Light.",
)
@click.option("--on", "-o", is_flag=True, help="Turn on the Key Light(s).")
def main(ip, port, on):
    print(f"Turning lights {'on' if on else 'off'} on port(s) {port} at {ip}")
    for p in port:
        r = requests.put(
            f"http://{ip}:{p}/elgato/lights", json={"lights": [{"on": on}]},
            timeout=5
        )
        print(f"Port: {p}, Light: {on}, Response Code: {r.status_code}")


if __name__ == "__main__":
    main(auto_envvar_prefix="KLIGHT")
