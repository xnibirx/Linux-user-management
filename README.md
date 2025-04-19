# Linux-user-management
A secure, menu-driven Bash script for managing Linux user accounts. Supports adding/removing users, modifying groups, changing shells, setting expiration dates, and more — with input validation and robust error handling.

# Linux User Management Script

This is a menu-driven Bash script to manage user accounts on a Linux system. It supports:

- Adding a new user
- Modifying initial and supplementary groups
- Changing login shell
- Setting account expiration
- Deleting user accounts

## Technologies
- Bash
- Linux CLI Tools (`useradd`, `usermod`, `userdel`, etc.)
- Error Handling with Redirection

## Usage
Run the script with root privileges:
```bash
sudo ./manage_users.sh
