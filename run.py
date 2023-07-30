import sys
import os
from dotenv import dotenv_values
config = dotenv_values("../../run/secrets/token")


def main():
    if config["TOKEN"] == "False":
        print(f"Missing bot token.")
        return

    if config["INTEGRATION"] == "discord":
        import classes.integrations.discord as DiscordIntegration
        DiscordIntegration.init(config["TOKEN"])
        
    elif config["INTEGRATION"] == "telegram":
        import classes.integrations.telegram as TelegramIntegration
        TelegramIntegration.init(config["TOKEN"])

    else:
        print("Expected valid Integration-type at command line argument 1, got " + str(config["INTEGRATION"]))


if __name__ == "__main__":
    main()
