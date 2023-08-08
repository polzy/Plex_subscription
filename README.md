
### Plex User Management Script
This script manages Plex Media Server (PMS) users based on their subscription end dates and sends notifications to Discord when a user with an expired subscription is streaming.

### Features:
CSV Backup: Automatically backs up the current CSV with user authorizations to a backup directory.
User Sync with Plex: Fetches users from PMS and syncs with the CSV.
Active Stream Monitoring: Lists active streaming users.
Subscription Verification: Checks for users with expired subscriptions.
User Termination: Kicks out users streaming with expired subscriptions.
Discord Notification: Sends a message to Discord when a user with an expired subscription is kicked.
### Configuration:
Set PMS IP, token, expiration message, CSV path, and Discord webhook in the configuration section.
Ensure the PSDiscord module is installed for Discord notifications.
### Usage:
Run the script regularly to monitor and manage active Plex users based on their subscription status.
