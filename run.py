import sys
import os
from get_docker_secret import get_docker_secret
import logging

def main():
    logging.basicConfig(filename='debug.log', encoding='utf-8', level=logging.INFO)
    discord_token = get_docker_secret('discord-token', default='None')
    import classes.integrations.discord as DiscordIntegration
    DiscordIntegration.init(discord_token)

if __name__ == "__main__":
    main()
