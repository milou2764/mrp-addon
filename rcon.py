from mcrcon import MCRcon

# Replace with your RCON password and port
RCON_IP = "54.37.39.245"
RCON_PORT = 27015  # Replace if your server uses a different port
RCON_PASSWORD = open('secret.txt').read()  # Replace with your RCON password
print('password', RCON_PASSWORD)

def rcon_command(command):
    try:
        # Connect to the server using RCON
        with MCRcon(RCON_IP, RCON_PASSWORD, RCON_PORT) as mcr:
            response = mcr.command(command)
            print(f"Server Response: {response}")
    except Exception as e:
        print(f"Failed to send RCON command: {e}")

# Example of sending a status command to the server
rcon_command("status")

