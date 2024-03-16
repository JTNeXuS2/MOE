#requests for install
# py -3 -m pip install -U disnake
# pip install requests
import disnake
from disnake.ext import commands
import requests
import json
import asyncio
import configparser
import re
import unicodedata
import datetime
from disnake.ext import commands
from disnake import Intents


def read_cfg():
    config = configparser.ConfigParser(interpolation=None)
    try:
        with open('config.ini', 'r', encoding='utf-8') as file:
            config.read_file(file)
    except FileNotFoundError:
        print("Ошибка: Файл конфигурации не найден.")
        return None
    return config

async def write_cfg(section, key, value):
    config = read_cfg()
    if f'{section}' not in config:
        config[f'{section}'] = {}
    config[f'{section}'][f'{key}'] = str(f'{value}')

    with open('config.ini', 'w', encoding='utf-8') as configfile:
        config.write(configfile)

def update_settings():
    global token, channel_id, message_id, additions, lookservers

    config = read_cfg()

    if config:
        try:
            token = config['botconfig']['token']
            channel_id = config['botconfig']['channel_id']
            message_id = config['botconfig']['message_id']
            additions = config['botconfig']['additions']
            # debug = config['botconfig']['debug']
            lookservers = {key: value for key, value in config['server'].items()}

        except KeyError as e:
            print(f"Ошибка: Не удалось найти соответствующие строки в конфигурационном файле: {e}")

token = None
channel_id = None
message_id = None
additions = None
prefix = '/'
lookservers = None
update_settings()

intents = disnake.Intents.default()
intents = disnake.Intents().all()
client = commands.Bot(command_prefix=prefix, intents=intents, case_insensitive=True)
bot = commands.Bot(command_prefix=prefix, intents=intents, case_insensitive=True)

async def get_server_data(server_list, value):
    ip, port = value.split(":")
    for server in server_list:
        server_data = None
        if server.get("addr") == ip and server.get("port") == int(port):
            server_data = server
            break
    return server_data

async def update():
    server_list = []
    embeds = []
    urls = [
        "https://l11-prod-list-moegame.angelagame.com/GameServerList_BigPrivate.json",
        "https://l11-prod-list-moegame.angelagame.com/GameServerList_Private.json",
        "https://l11-prod-list-moegame.angelagame.com/GameServerList_Listen.json"
    ]

    addition_embed = disnake.Embed(
        title=f"",
        description=f"",
    )
    embeds.append(addition_embed)

    for url in urls:
        response = requests.get(url)
        data = response.json()
        server_list.extend(data.get('server_list', []))
    
    lookservers_values = list(lookservers.values())
    for key, value in lookservers.items():
        server_data = await get_server_data(server_list, value)
        if not server_data:
            offline_embed = disnake.Embed(
                title=f"{key} Offline :red_circle:",
                description=f"{key} adress {value} is currently offline or not found",
                color=disnake.Color.red()
            )
            embeds.append(offline_embed)
        else:
            custom_info = json.loads(server_data['custom_info'])
            #Localize
            local_map = custom_info['map_name']
            match local_map:
                case "LargeTerrain_Central2_Main":
                    local_map = "Восточные острова"
                case "LargeTerrain_Central_Main":
                    local_map = "Центральная равнина"
                case "Map_Lobby":
                    local_map = "Лобби"
                case "Battlefield_Main_New":
                    local_map = "Поле битвы"
                case _:
                    local_map = "UNKNOWN"

            color = disnake.Color.random()
            embed = disnake.Embed(
                title=server_data.get('name', 'N/A'),
                description=f"Map: {local_map}\n:green_circle: Online: {server_data.get('online', '0')}/{custom_info.get('maxplayer', '0')}\nDescription: {custom_info.get('desc', 'N/A')}",
                color=disnake.Color.green()
            )
            embeds.append(embed)

    #print(f'embeds')
    masstitle = ""
    masstext = ""
    for embed in embeds:
        masstext += f'\n**{embed.title}**\n' if embed.title else ''
        masstext += f'{embed.description}\n' if embed.description else ''
    
    addition_embed = disnake.Embed(
        title=f"{additions}",
        description=f"{masstext}",
    )
    return addition_embed

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')
    print('Invite bot link to discord (open in browser):\nhttps://discord.com/api/oauth2/authorize?client_id='+ str(bot.user.id) +'&permissions=8&scope=bot\n')
    while True:
        #channel_id = None
        #message_id = None
        update_settings()
        try:
            channel = await bot.fetch_channel(channel_id)
            message = await channel.fetch_message(message_id)
            addition_embed = await update()
            if message:
                await message.edit(content=f'Last update: {datetime.datetime.now().strftime("%H:%M")}', embed=addition_embed)
        except Exception as e:
            print(f'Failed to fetch channel or message. Maybe try /sendhere\n {e}')

        await asyncio.sleep(30)

@bot.slash_command(description="Show commands list")
async def help(ctx):
    await ctx.send('**==Support commands==**\n'
    f' Show commands list```{prefix}help```'
    f' Show server status```{prefix}moestatus```'
    f'\n **Need admin rights**\n'
    f' Auto send server status here```{prefix}sendhere```'
    f' Add server to listing```{prefix}serveradd adress:port name```',
    ephemeral=True
    )

@bot.slash_command(description="Request Servers status")
async def moestatus(ctx):
    try:
        addition_embed = await update()
        await ctx.response.send_message(embed=addition_embed, ephemeral=True)
    except Exception as e:
        await ctx.response.send_message(f'❌ Please try again later.', ephemeral=True)
        print(f'Error occurred during file write: {e}')


@bot.slash_command(description="Set this channel to announce")
async def sendhere(ctx: disnake.ApplicationCommandInteraction):
    if ctx.author.guild_permissions.administrator:
        try:
            guild = ctx.guild
            print(f'New channel id - {ctx.channel.id}')
            await write_cfg('botconfig', 'channel_id', str(ctx.channel.id))
            channel = await guild.fetch_channel(ctx.channel.id)
            await ctx.response.send_message(content=f'This message for auto updated the status', ephemeral=False)

            last_message = await ctx.channel.fetch_message(ctx.channel.last_message_id)
            print(f'New message id - {last_message.id}')
            await write_cfg('botconfig', 'message_id', str(last_message.id))
            update_settings()

        except Exception as e:
            await ctx.response.send_message(content='❌ An error occurred. Please try again later.', ephemeral=True)
            print(f'Error occurred during file write: {e}')
    else:
        await ctx.response.send_message(content='❌ You do not have permission to run this command.', ephemeral=True)


@bot.slash_command(description="Add server to listing")
async def serveradd(ctx: disnake.ApplicationCommandInteraction, address: str, port: int, name: str):
    if ctx.author.guild_permissions.administrator:
        try:
            await write_cfg('server', f'{name}', f'{address}:{port}')
            update_settings()
        
            await ctx.response.send_message(f'Server added: {address}:{port} ({name})', ephemeral=True)
        except Exception as e:
            await ctx.response.send_message(f'❌ An error occurred while trying to add the server. Please try again later.', ephemeral=True)
            print(f'Error occurred during file write: {e}')
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
