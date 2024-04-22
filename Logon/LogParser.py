import disnake
from disnake.ext import commands
from disnake import Intents
import json
import configparser
import unicodedata
import datetime

import asyncio
import os
# Need "pip install requests"
import requests
import time
import re
import subprocess
#pip install ipwhois
#from ipwhois import IPWhois
import proxycheck

#from pytonik_ip_vpn_checker.ip import ip
#Set discord webhook URL
webhook_url = "https://discord.com/api/webhooks/1214978965471756418/444444444444444444444444444444444444444444"
filename = 'wl.txt'
token = 'BOT TOKEN lsadklasdk;laksdlas;d'
prefix = '/'
apikey="get in https://proxycheck.io"

#Set admins SteamIDs, add custom param to find
id_list = ['PostLogin Account: 76561198277462764', 'PostLogin Account: 76561198838209834', 'PostLogin Account: 76561198126416023',
    'OnLoadPlayerDataComplete AccountId 76561198277462764',
    'OnLoadPlayerDataComplete AccountId 76561198838209834',
    'OnLoadPlayerDataComplete AccountId 76561198126416023',
    'ServerCheat_Implementation', 'LobbyCheat', 'ASGGameModeLobby', 'remote console, exec:']

#Set full path to servers logs
log_files = [
    'C:/moe_cluster/moe/MOE/Saved/Logs/PubDataServer_6010.log',
    'C:/moe_cluster/moe/MOE/Saved/Logs/LobbyServer_6000.log',
    'C:/moe_cluster/moe/MOE/Saved/Logs/SceneServer_100.log',
    'C:/moe_cluster/moe/MOE/Saved/Logs/SceneServer_200.log',
    'C:/moe_cluster/moe/MOE/Saved/Logs/SceneServer_300.log'
]

#Set match the server name and log file
log_files_dict = {
    'PubDataServer_6010.log': 'Кластер: Lobby',
    'LobbyServer_6000.log': 'Кластер: Lobby',
    'SceneServer_100.log': 'Кластер: PVE1',
    'SceneServer_200.log': 'Кластер: PVP',
    'SceneServer_300.log': 'Кластер: PVE2'
}

#Nothing change more

intents = disnake.Intents.default()
intents = disnake.Intents().all()
client = commands.Bot(command_prefix=prefix, intents=intents, case_insensitive=True)
bot = commands.Bot(command_prefix=prefix, intents=intents, case_insensitive=True)

missing_files = []
for log_file in log_files:
    if not os.path.exists(log_file):
        missing_files.append(log_file)

if missing_files:
    missing_files_str = "\n".join(missing_files)
    print(f"The following files are missing:")
    print(missing_files_str)
else:
    print("All log files are present.")

async def read_log_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.readlines()
    except FileNotFoundError:
        #print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] File not found: {file_path}")
        return []

async def send_discord_webhook(webhook_url, message):
    data = {'content': message}
    try:
        requests.post(webhook_url, json=data)
    except Exception as e:
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Error sending Discord webhook: {e}")

def append_to_file(data):
    filename = 'db.txt'
    try:
        with open(filename, 'r', encoding='utf-8'):
            pass
    except FileNotFoundError:
        with open(filename, 'w', encoding='utf-8'):
            pass

    with open(filename, 'a', encoding='utf-8') as file:
        file.write(str(data) + '\n')
def read_bl():
    try:
        with open('blacklist.txt', 'r', encoding='utf-8') as file:
            blacklist = [line.strip() for line in file.readlines()]
        return blacklist
    except FileNotFoundError:
        return

def read_wl():
    try:
        with open('wl.txt', 'r') as file:
            whitelist = [line.strip() for line in file.readlines()]
        return whitelist
    except FileNotFoundError:
        return
def add_wl(steamid):
    try:
        whitelist = read_wl()    
        if steamid not in whitelist:
            with open('wl.txt', 'a', encoding='utf-8') as file:
                file.write(steamid + '\n')
            return 1
        return 0
    except Exception as e:
        print(f"Error appending to file: {e}")
    return 0
def del_wl(steamid):
    whitelist = read_wl()
    if steamid not in whitelist:
        print(f"SteamID {steamid} not found in whitelist. Error: SteamID not found")
        return
    whitelist.remove(steamid)
    try:
        with open('wl.txt', 'w', encoding='utf-8') as file:
            for item in whitelist:
                file.write(item + '\n')
        print(f'SteamID {steamid} successfully removed from whitelist.')
    except Exception as e:
        print(f"Error writing to file: {e}")

def is_vpn_ip(ip_address):
    obj = IPWhois(ip_address)
    results = obj.lookup_whois()

    vpn_providers = ['VPN', 'PureVPN', 'ExpressVPN', 'NordVPN']  # Примеры провайдеров VPN
    is_vpn = any(provider in results.get('category', []) for provider in vpn_providers)
    return is_vpn

def check_dns_leak(ip_address):
    response = requests.get(f'https://www.dnsleaktest.com/api/v1/ip/{ip_address}')
    if response.ok:
        data = response.json()
        dns_leak = data.get('is_vpn', False)
        return dns_leak
    return False

def check_webrtc_leak(ip_address):
    response = requests.get(f'https://www.browserleaks.com/webrtc/ip/{ip_address}')
    if response.ok:
        data = response.json()
        webrtc_leak = data.get('is_vpn', False)
        return webrtc_leak
    return False

async def calculate_vpn_probability(ip_address):
    vpn_counter = 0
    total_tests = 3

    if is_vpn_ip(ip_address):
        vpn_counter += 1
    else:
        total_tests -= 1

    if check_dns_leak(ip_address):
        vpn_counter += 1
    else:
        total_tests -= 1

    if check_webrtc_leak(ip_address):
        vpn_counter += 1
    else:
        total_tests -= 1

    vpn_probability = (vpn_counter / total_tests) * 100 if total_tests > 0 else 0
    return vpn_probability

async def ipcheck(Address):
    try:
        client = proxycheck.Awaiting(key=apikey)
        ip = client.ip(Address)
        return await ip.proxy()
    except Exception as e:
        # Обработка исключения, если оно произошло
        print(f"Произошла ошибка при проверке IP адреса: {e}")
        return await ip.proxy()

async def registration(line, server_name):
    match = re.search(r"NickName = ([^\n,]+), UniqueId = (\d+), Address = ([\d.]+), Port = (\d+), DeviceId = (\w+)", line)
    Address = None
    Isvpn = 0
    if match:
        NickName = match.group(1)
        UniqueId = match.group(2)
        Address = match.group(3)
        Port = match.group(4)
        DeviceId = match.group(5)
        #Isvpn = await calculate_vpn_probability(Address)
        try:
            Isvpn = await ipcheck(Address)
        except Exception as e:
            print(f'ERROR VPN ECHECK \n {e}')
        result_tuple = f'{NickName}, {UniqueId}, {Address}, {Port}, {DeviceId}'
        print(f'>>>>>Address: {Address} VPN: {Isvpn}')

        with open('db.txt', 'r', encoding='utf-8') as f:
            lines = f.readlines()
            found = False

            for index, entry in enumerate(lines):
                if UniqueId in entry:
                    found = True
                    whitelist = read_wl()
                    if UniqueId in whitelist:
                        print(f"SteamID {UniqueId} in the whitelist!")
                        break
                    parts = entry.strip().split(', ')

                    if DeviceId != parts[-1].strip(): # Проверка на несовпадение DeviceId
                        print(f'BAN >>>>>> "{Address}" VPN: {Isvpn}%\n')
                        #subprocess.run(f'cmd.exe /c netsh advfirewall firewall add rule name="Block Specific IP {Address}" dir=in action=block protocol=TCP remoteip={Address}', shell=True)
                        subprocess.run(f'cmd.exe /c netsh advfirewall firewall add rule name="Block Specific IP" dir=in action=block protocol=TCP remoteip={Address}', shell=True)
                        await send_discord_webhook(webhook_url, f"{server_name} @here CHEATER Login ```({result_tuple})```\n VPN: {Isvpn}")
                    else:
                        parts[0] = NickName
                        parts[2] = Address
                        parts[3] = Port
                        updated_entry = ', '.join(parts)
                        lines[index] = updated_entry + '\n'

                    break

            if not found:
                append_to_file(result_tuple)  # Добавляем новую запись, если не найдено совпадений
                return Isvpn

        with open('db.txt', 'w', encoding='utf-8') as f:
            f.writelines(lines)  # Перезаписываем файл с обновленными значениями
        return Isvpn
    else:
        #print("No match found in the log string.")
        return Isvpn

last_lines = {os.path.basename(log_file): None for log_file in log_files}
async def process_log_file(log_file):
    log_lines = await read_log_file(log_file)
    log_filename = os.path.basename(log_file)
    
    if log_filename in last_lines:
        if last_lines[log_filename] is not None:
            new_lines = log_lines[last_lines[log_filename] or 0:]
            for line in new_lines:
                if any(id in line for id in id_list):
                    if re.match(r'\[\d{4}\.\d{2}\.\d{2}-\d{2}\.\d{2}\.\d{2}:\d{1,}\]\[\d{1,}\](LogSG|LogSGGM):', line):
                        server_name = log_files_dict.get(log_filename, "Unknown Server")
                        Isvpn = 0
                        Isvpn = await registration(line, server_name)
                        Isvpn = '' if Isvpn == 0 else f'VPN: **{Isvpn}**'
                        print(f"{server_name} ```({log_filename}): {line}```\n")
                        await send_discord_webhook(webhook_url, f"{server_name}\n{Isvpn}```({log_filename}): {line}```")
        last_lines[log_filename] = len(log_lines)
    else:
        print(f"Key '{log_filename}' not found in last_lines dictionary")


async def main():
    while True:
        tasks = [process_log_file(log_file) for log_file in log_files]
        await asyncio.gather(*tasks)
        await asyncio.sleep(3)  # Проверка каждые 10 секунд
        #print(f'ChekLogs')

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')
    print('Invite bot link to discord (open in browser):\nhttps://discord.com/api/oauth2/authorize?client_id='+ str(bot.user.id) +'&permissions=8&scope=bot\n')
    await main()

@bot.slash_command(description="Add SteamID to Whitelist")
async def addsteam(ctx: disnake.ApplicationCommandInteraction, steamid: str):
    if ctx.author.guild_permissions.administrator:
        cmd = f'netsh advfirewall firewall delete rule name="Block Specific IP"'
        subprocess.run(cmd, shell=True, capture_output=True, text=True)
        status = add_wl(steamid)
        try:
            if status:
                await ctx.send(f'SteamID: {steamid} :white_check_mark: \nAdded to WhiteList', ephemeral=True)
            if not status:
                await ctx.send(f'SteamID: {steamid} :negative_squared_cross_mark: \nAlready on the WhiteList', ephemeral=True)
        except Exception as e:
            await ctx.send(f'ERROR Adding SteamID: {steamid} to WhiteList', ephemeral=True)
    else:
        await ctx.response.send_message("❌ You do not have permission to run this command.", ephemeral=True)

@bot.slash_command(description="Show White List")
async def showlist(ctx):
    if ctx.author.guild_permissions.administrator:
        whitelist = '\n'.join(read_wl())
        await ctx.send(f'WhiteList:\n{whitelist}', ephemeral=True)
    else:
        await ctx.response.send_message("❌ You do not have permission to run this command.", ephemeral=True)

@bot.slash_command(description="Show Black List")
async def showblacklist(ctx):
    if ctx.author.guild_permissions.administrator:
        blacklist = read_bl()
        
        blacklist_str = '\n'.join(blacklist)
        
        if len(blacklist_str) <= 1900:
            await ctx.send(f'blacklist:\n{blacklist_str}', ephemeral=True)
        else:
            parts = [blacklist_str[i:i+1900] for i in range(0, len(blacklist_str), 1900)]
            for part in parts:
                await ctx.send(f'blacklist (part):\n{part}', ephemeral=True)
    else:
        await ctx.response.send_message("❌ You do not have permission to run this command.", ephemeral=True)

@bot.slash_command(description="Delete SteamID from Whitelist")
async def delsteam(ctx: disnake.ApplicationCommandInteraction, steamid: str):
    if ctx.author.guild_permissions.administrator:
        del_wl(steamid)
        try:
            await ctx.send(f'SteamID: {steamid}\nDeleted from WhiteList', ephemeral=True)
        except Exception as e:
            await ctx.send(f'ERROR Deleting SteamID: {steamid} from WhiteList', ephemeral=True)
    else:
        await ctx.response.send_message("❌ You do not have permission to run this command.", ephemeral=True)

@bot.slash_command(description="UnBan All IP")
async def unban_ip(ctx: disnake.ApplicationCommandInteraction, ip_address: str):
    if ctx.author.guild_permissions.administrator:
        #cmd = f'cmd.exe /c netsh advfirewall firewall delete rule name="Block Specific IP {ip_address}"'
        try:
            #subprocess.run(cmd, shell=True)
            #await ctx.send(f'All rules with name "Block Specific IP {ip_address}" have been deleted', ephemeral=True)
            cmd = f'netsh advfirewall firewall delete rule name="Block Specific IP"'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            await ctx.send(f'All rules with name "Block Specific IP have been deleted! {result.stderr}', ephemeral=True)
        except subprocess.CalledProcessError as e:
            await ctx.send(f'An error occurred while deleting rules: {e}', ephemeral=True)
    else:
        await ctx.response.send_message("❌ You do not have permission to run this command.", ephemeral=True)

try:
    bot.run(token)
except disnake.errors.LoginFailure:
    print(' Improper token has been passed.\n Get valid app token https://discord.com/developers/applications/ \nscreenshot https://junger.zzux.com/webhook/guide/4.png')
except disnake.HTTPException:
    print(' HTTPException Discord API')
except disnake.ConnectionClosed:
    print(' ConnectionClosed Discord API')
except disnake.errors.PrivilegedIntentsRequired:
    print(' Privileged Intents Required\n See Privileged Gateway Intents https://discord.com/developers/applications/ \nscreenshot http://junger.zzux.com/webhook/guide/3.png')
except httpx.ConnectTimeout as e:
    print(f"ConnectTimeout when making an HTTP request: {e}")
except httpx.ReadTimeout as e:
    print(f'ReadTimeout при ожидании ответа: {e}')
except Exception as e:
    print(f'Произошла другая ошибка: {e}')
