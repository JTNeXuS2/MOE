#!/usr/bin/python3
import time
import json
from dotenv import load_dotenv
import os
import glob
import sqlite3
import csv
from datetime import datetime, timedelta
import requests
import subprocess
import random
import asyncio

load_dotenv()

log_directory = os.getenv('LOG_DIRECTORY', 'C:\\moenew\\MatrixServerTool\\chat_logs\\')
channel_names = {channel.split('=')[0]: channel.split('=')[1] for channel in os.getenv('CHANNEL_FRIENDLY_NAMES', '').split(',') if '=' in channel}
local_channels = list(channel_names.keys())
webhook_url = os.getenv('DISCORD_WEBHOOK')
rcon_path = os.getenv('RCON_PATH')
rcon_password = os.getenv('RCON_PASSWORD')
chat_url = os.getenv('CHAT_WEBHOOK')

#print(f"channel:server\n {channel_names}")

# Mapping of channel friendly names to RCON Ports.

port_mapping_str = os.getenv("PORT_MAPPING")
port_mapping = {key: value for key, value in [pair.split('=') for pair in port_mapping_str.split(',')]}

db_config = {
    'host': os.getenv('DB_HOST', '127.0.0.1'),
    'port': os.getenv('DB_PORT', '3306'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'root'),
    'database': os.getenv('DB_DATABASE', 'moe_role')
}

annonce_servers = [(address.split('=')[0], address.split('=')[1]) for address in os.getenv('NOTIFY_IP_PORTS', '').split(',') if '=' in address]
announcement_cd = os.getenv('ANONCE_CD')
#print(f"annonce_servers\n {annonce_servers}")

db_path = os.getenv('DATABASE_PATH', 'C:\\Moenew\\WindowsPrivateServer\\MOE\\Saved\\SaveGames\\BigPrivate\\moe_role.db')

csv_file_path = 'account_log.csv'
announcement_file = 'announcement.txt'
logging_file = 'Commands.log'

def log_to_file(text):
    today = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    string = f"{today} >> {text}"
    try:
        with open(logging_file, 'a', encoding='utf-8') as file:
            file.write(string + '\n')
    except Exception as e:
        print(f"Error while logging to file: {e}")

kits = []
for filename in os.listdir('kits'):
    if filename.endswith('.txt'):
        file_name = os.path.splitext(filename)[0]
        kits.append(file_name)

def initialize_csv():
    try:
        with open(csv_file_path, 'a+', newline='') as csvfile:
            csvfile.seek(0)
            if not csvfile.read(1):
                writer = csv.writer(csvfile)
                writer.writerow(['s_account_uid', 'from_nick', 'Date', 'Status', 'Kit'])
    except IOError as e:
        print(f"IO Error while initializing CSV file: {e}")


initialize_csv()

def execute_kit(channel_friendly_name, s_account_uid, kit_name):

    # Mapping of channel friendly names to RCON Ports.
    port_mapping = {
        "100": "8012",
        "200": "8022",
        "300": "8032"
    }
    port = port_mapping.get(channel_friendly_name, "1234")
    commands = []

    try:
        with open(f'kits/{kit_name}.txt', 'r') as file:
            lines = file.readlines()
            first_line = lines[0].strip()
            if first_line == "random":
                random_line = random.choice(lines[1:])
                modified_line = f"{rcon_path}mcrcon.exe -H 65.109.113.61 -P {port} -p {rcon_password} -w 5 \"{random_line.strip().replace('{s_account_uid}', s_account_uid)}\""
                commands.append(modified_line)
            else:
                for line in lines[1:]:
                    modified_line = f"{rcon_path}mcrcon.exe -H 65.109.113.61 -P {port} -p {rcon_password} -w 5 \"{line.strip().replace('{s_account_uid}', s_account_uid)}\""
                    commands.append(modified_line)

    except FileNotFoundError:
        print("Kit not found.")
        return
    return commands, first_line

def execute_commands(commands):
    for command in commands:
        print(f"\nSent command >>\n {command}")
        subprocess.run(command, check=True, shell=True)
        log_to_file(f'Send>> {command}')

def process_account(account_id, from_nick, to_channel, kit_name):
    today = datetime.now()
    found = False
    accounts = []
    channel_friendly_name = channel_names.get(to_channel, "Unknown Channel")
    log_to_file(f'{channel_friendly_name}: {account_id}:{from_nick}: type>> {kit_name}')
    try:
        with open(csv_file_path, 'r', newline='') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)

            for row in reader:
                if row[0] == account_id and row[4] == f'{kit_name}':
                    found = True
                    row_datetime = datetime.strptime(row[2], '%Y-%m-%d %H:%M:%S')
                    if today < row_datetime and row[3] == '0':
                        print(f"User {from_nick} has already executed the command today.")
                        log_to_file(f"User {from_nick} has already executed the command today.")
                        return
                    elif row[3] != '0':
                        print(f"User {from_nick} is banned.")
                        return
                    else:
                        commands, first_line = execute_kit(channel_friendly_name, account_id, kit_name)
                        cooldown = first_line.split(',')[1] if ',' in first_line else 1440
                        print(f"Kit>> {kit_name} CD>> {cooldown}")
                        row[2] = (today + timedelta(minutes=int(cooldown))).strftime('%Y-%m-%d %H:%M:%S')
                        print(f"Date for user {from_nick} is being updated to today.")
                        execute_commands(commands)
                        send_to_discord(channel_friendly_name, from_nick, f'Claimed their daily login reward by typing *** /{kit_name} *** into Nearby chat')
                accounts.append(row)
        sorted_accounts = sorted(accounts, key=lambda x: x[1])

        with open(csv_file_path, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(header)
            writer.writerows(sorted_accounts)
            if not found:
                commands, first_line = execute_kit(channel_friendly_name, account_id, kit_name)
                cooldown = first_line.split(',')[1] if ',' in first_line else 1440
                print(f"Kit>> {kit_name} CD>> {cooldown}")
                cooldown_date = (today + timedelta(minutes=int(cooldown))).strftime('%Y-%m-%d %H:%M:%S')
                writer.writerow([account_id, from_nick, cooldown_date, '0', kit_name])
                print(f"Entry for user {from_nick} has been added.")
                log_to_file(f"Entry for user {from_nick} has been added.")
                execute_commands(commands)
                send_to_discord(channel_friendly_name, from_nick, f'Claimed their daily login reward by typing *** /{kit_name} *** into Nearby chat')

    except IOError as e:
        print(f"IOError while processing account: {e}")

import mysql.connector
from mysql.connector import Error

def get_account_id(s_role_uid):
    db_config = {
        'host': '65.109.113.61',
        'port': '3306',
        'user': 'sql_user',
        'password': 'sql_password',
        'database': 'moe_role'
    }
    try:
        conn = mysql.connector.connect(
            host=db_config['host'],
            port=db_config['port'],
            user=db_config['user'],
            password=db_config['password'],
            database=db_config['database']
        )
        cursor = conn.cursor()
        cursor.execute("SELECT s_account_id FROM moe_roles WHERE s_role_uid = %s", (s_role_uid,))
        account_id = cursor.fetchone()
        cursor.close()
        conn.close()
        data = account_id[0]
        decoded_str = data.decode('utf-8')
        return decoded_str if decoded_str else None
    except Error as e:
        print(f"Database error: {e}")
        return None

def find_latest_file(directory):
    list_of_files = glob.glob(f'{directory}*')
    latest_file = max(list_of_files, key=os.path.getctime)
    return latest_file

def watch_log_file(directory):
    current_file = find_latest_file(directory)
    file_position = os.path.getsize(current_file)

    while True:
        try:
            new_file = find_latest_file(directory)
            if new_file != current_file:
                current_file = new_file
                file_position = 0

            with open(current_file, 'r', encoding='utf-8') as file:
                file.seek(file_position)
                lines = file.readlines()
                file_position = file.tell()

            for line in lines:
                process_line(line)

        except Exception as e:
            print(f"Error encountered: {e}")
            time.sleep(5)
            continue

        time.sleep(1)

def check_csv_for_entry(from_role_uid):
    today = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(csv_file_path, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['s_account_uid'] == from_role_uid:
                is_today = row['Date'] == today
                return True, is_today
    return False, False

def process_line(line):
    try:
        log_entry = json.loads(line)
        to_channel = log_entry.get("to")
        if to_channel in local_channels:
            from_role_uid = log_entry.get("from")
            from_nick = log_entry.get("from nick", "Unknown")
            content = log_entry.get("content", "")
            get_kit = f'{content.split('/')[-1]}'

            for kit_name in kits:
                if f"/{kit_name}" == f"/{get_kit}":
                    entry_exists, is_today = check_csv_for_entry(from_role_uid)

                    if entry_exists and is_today:
                        print(f"User {from_nick} has already executed the command today, skipping database query.")
                        return

                    account_id = get_account_id(from_role_uid)
                    if account_id:
                        process_account(account_id, from_nick, to_channel, kit_name)
                    else:
                        print(f"Account ID not found for the given role UID: {from_role_uid}.")
                    break
    except json.JSONDecodeError as e:
        print(f"chat JSON decode error: {e}")

def send_to_discord(channel_friendly_name, from_nick, content):
    def escape_markdown(text):
        markdown_chars = ['\\', '*', '_', '~', '`', '>', '|']
        for char in markdown_chars:
            text = text.replace(char, '\\' + char)
        return text

    def truncate_message(text, max_length=2000):
        return text if len(text) <= max_length else text[:max_length-3] + '...'
    from_nick = escape_markdown(from_nick)
    content = escape_markdown(content)
    content = truncate_message(content)
    message = f"**{channel_friendly_name}**:\n**{from_nick}**: {content}"
    data = {"content": message}
    response = requests.post(webhook_url, json=data)
    if response.status_code != 204:
        print(f"Error sending message to Discord: {response.status_code} - {response.text}")


watch_log_file(log_directory)
