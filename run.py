import sys
import os
from get_docker_secret import get_docker_secret


def main():
    import integrations.discord
    discord_token = get_docker_secret('discord-token', default='None')
    integrations.discord.init(discord_token)

if __name__ == "__main__":
    main()
