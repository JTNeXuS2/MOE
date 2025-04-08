import tkinter as tk
from tkinter import messagebox, scrolledtext
import re
import random
import mysql.connector
import os

def read_config(file_path='configs.cfg'):
    config = {}
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            for line in file:
                # Strip whitespace and ignore empty lines or comments
                line = line.strip()
                if line and not line.startswith('#'):
                    key, value = line.split('=', 1)  # Split on the first '='
                    config[key.strip()] = value.strip()
        
        # Extracting values
        host = config.get('host', '127.0.0.1')  # Default value
        port = int(config.get('port', 3306))    # Default value
        user = config.get('user', 'moe_cluster')  # Default value
        password = config.get('password', 'Sql db PASSWORD')  # Default value
        database = config.get('database', 'moe_opt')  # Default value

        return host, port, user, password, database
    else:
        return None

ready = 0
directory = "save"
config_values = read_config()
if config_values:
    host, port, user, password, database = config_values
    #print(f"Host: {host}\nPort: {port}\nUser: {user}\nPassword: {password}\nDatabase: {database}")

class SQLInsertEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("SQL Insert Editor")
        
        # Создаем фрейм для левой части окна
        self.left_frame = tk.Frame(root)
        self.left_frame.pack(side="left", fill="both", expand=True, padx=5, pady=5)

        self.read_from_db_button = tk.Button(self.left_frame, text="Read From DB", command=self.read_from_db)
        self.read_from_db_button.pack(fill='x', expand=True)


        self.sql_input_label = tk.Label(self.left_frame, text="Input SQL string:")
        self.sql_input_label.pack(fill='both', expand=True)

        self.sql_input = tk.Text(self.left_frame, height=5)
        self.sql_input.pack(fill='both', expand=True)

        # parse_frame
        self.parse_frame = tk.Frame(self.left_frame)
        self.parse_frame.pack(fill='x', expand=True)

        self.parse_button = tk.Button(self.parse_frame, text="Parse", command=self.parse_sql)
        self.parse_button.pack(side='left', fill='x', expand=True)

        self.autoparse = True
        self.autoparse_var = tk.BooleanVar(value=self.autoparse)
        self.autoparse_checkbox = tk.Checkbutton(self.parse_frame, text="Auto Parse", variable=self.autoparse_var, command=self.toggle_autoparse)
        self.autoparse_checkbox.pack(side='left', padx=(5, 0))  # Отступ справа от кнопки

        self.fields_frame = tk.Frame(self.left_frame)
        self.fields_frame.pack(fill='both', expand=True)

        self.canvas = tk.Canvas(self.fields_frame)
        self.scrollbar = tk.Scrollbar(self.fields_frame, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = tk.Frame(self.canvas)

        self.scrollable_frame.bind("<Configure>", lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")))
        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.canvas.bind("<MouseWheel>", lambda e: self.canvas.yview_scroll(int(-1*(e.delta/120)), "units"))

        self.canvas.pack(side="left", fill="both", expand=True)
        self.scrollbar.pack(side="right", fill="y")

        self.fields_frame.grid_columnconfigure(0, weight=1)
        self.fields_frame.grid_columnconfigure(1, weight=0)

        self.fields = []
        self.entries = []

        # fill_dates_frame
        self.fill_dates_frame = tk.Frame(self.left_frame)
        self.fill_dates_frame.pack(fill='x', expand=True)

        self.fill_dates_button = tk.Button(self.fill_dates_frame, text="Fills Dates/IDs/Price", command=self.fill_dates)
        self.fill_dates_button.pack(side='left', fill='x', expand=True)

        self.lockid = True
        self.lockid_var = tk.BooleanVar(value=self.lockid)
        self.lockid_checkbox = tk.Checkbutton(self.fill_dates_frame, text="Lock GoodsID", variable=self.lockid_var, command=self.toggle_lockid)
        self.lockid_checkbox.pack(side='left', padx=(5, 0))  # Отступ справа от кнопки

        # gen_write_frame
        self.gen_write_frame = tk.Frame(self.left_frame)
        self.gen_write_frame.pack(fill='x', expand=True)

        self.generate_button = tk.Button(self.gen_write_frame, text="Generate SQL", command=self.generate_sql)
        self.generate_button.pack(side='left', fill='x', expand=True)

        self.genwrite = True
        self.genwrite_var = tk.BooleanVar(value=self.genwrite)
        self.genwrite_checkbox = tk.Checkbutton(self.gen_write_frame, text="Auto Generate", variable=self.genwrite_var, command=self.toggle_genwrite)
        self.genwrite_checkbox.pack(side='left', padx=(5, 0))  # Отступ справа от кнопки
        
      
        self.updated_sql_output = scrolledtext.ScrolledText(self.left_frame, height=10)
        self.updated_sql_output.pack(fill='both', expand=True)

        self.write_to_db_button = tk.Button(self.left_frame, text="Write To DB", command=self.generate_sql_and_write_to_db)
        self.write_to_db_button.pack(fill='x', expand=True)

        # Блок для отображения файлов .sql в правой части окна
        self.file_list_frame = tk.Frame(root)
        self.file_list_frame.pack(side="right", fill="y", expand=False, padx=5, pady=5)

        self.file_list_label = tk.Label(self.file_list_frame, text="SQL Files:")
        self.file_list_label.pack(fill='x')
        
        self.file_list_button = tk.Button(self.file_list_frame, text="Refresh list", command=self.load_sql_files)
        self.file_list_button.pack(fill='x', padx=(0, 0), pady=(5, 5), expand=False)
        
        self.file_listbox = tk.Listbox(self.file_list_frame)
        self.file_listbox.pack(fill='both', expand=True)
        
        self.file_listbox.bind('<<ListboxSelect>>', self.load_sql_file)
        
        self.load_sql_files()

    def load_sql_files(self):
        if not os.path.exists(directory):
            os.makedirs(directory)

        sql_files = [f for f in os.listdir(directory) if f.endswith('.sql') or f.endswith('.txt')]
        self.file_listbox.delete(0, tk.END)
        for file in sql_files:
            self.file_listbox.insert(tk.END, file)

    def load_sql_file(self, event):
        selected_index = self.file_listbox.curselection()
        if selected_index:
            file_name = self.file_listbox.get(selected_index)
            file_path = os.path.join(directory, file_name)
            
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    sql_content = file.read()
                    self.sql_input.delete(1.0, tk.END)
                    self.sql_input.insert(tk.END, sql_content)
                if self.autoparse:
                    self.parse_sql()
            except Exception as e:
                messagebox.showerror("Error", f"Could not read file: {e}")
                self.load_sql_files()

    def generate_sql_and_write_to_db(self):
        global ready
        if ready:
            if self.genwrite:
                self.generate_sql()
            self.write_to_db()
        else:
            messagebox.showinfo("Info", "No data to write to the table. Input SQL is clear!")
			
    def toggle_lockid(self):
        self.lockid = self.lockid_var.get()
    def toggle_autoparse(self):
        self.autoparse = self.autoparse_var.get()
    def toggle_genwrite(self):
        self.genwrite = self.genwrite_var.get()

    def write_to_db(self):
        sql = self.updated_sql_output.get("1.0", tk.END).strip()  # Получаем текст из поля
        try:
            connection = mysql.connector.connect(host=host, port=port, user=user, password=password, database=database)
            cursor = connection.cursor()
            cursor.execute(sql)
            connection.commit()
            print("Success Write data to Database Sell_goods.")
            messagebox.showinfo("Success", "Data has been successfully inserted into the database Shop.")
        except mysql.connector.Error as err:
            if err.errno == 1062:
                error_message = f"Error: Change ID, must be unique. just add 10000.\n{err}"
            else:
                error_message = f"Error: {err}"
            print(f"Error: {err}")
            messagebox.showerror("Ошибка", error_message)
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()

    def read_from_db(self):
        keywords = ['GeneralName', 'GeneralPath', 'AnimalPath', 'AnimalName']
        
        # Обновленный запрос с подзапросом для замены acc_id на s_account_id
        query = """
    SELECT 
        CAST(mr.s_account_id AS CHAR) AS acc_id,
        sg.goods_id, 
        sg.name, 
        sg.type, 
        sg.count, 
        sg.price, 
        sg.icon, 
        sg.`desc`, 
        sg.rule, 
        sg.bp_id, 
        sg.publicity_period, 
        sg.expire_date, 
        HEX(sg.data) AS hex_data, 
        sg.seller_id, 
        sg.seller_name, 
        sg.status, 
        sg.server_id, 
        sg.district_id, 
        sg.trading_volume, 
        sg.received, 
        sg.rule0, 
        sg.rule1, 
        sg.rule2, 
        sg.rule3, 
        sg.rule4, 
        sg.rule5, 
        sg.rule6, 
        sg.rule7, 
        sg.type0, 
        sg.type1, 
        sg.type2, 
        sg.type3, 
        sg.type4, 
        sg.type5, 
        sg.type6, 
        sg.type7, 
        sg.id, 
        sg.created_at, 
        sg.updated_at, 
        sg.deleted_at 
    FROM 
        sell_goods sg 
    LEFT JOIN 
        moe_role.moe_roles mr ON mr.s_role_uid = sg.acc_id
    WHERE 
        sg.`desc` LIKE %s
    """
        
        # Объединяем условия для LIKE
        like_conditions = " OR ".join(["sg.`desc` LIKE %s"] * len(keywords))
        query = query.replace("sg.`desc` LIKE %s", like_conditions)

        params = [f"%{keyword}%" for keyword in keywords]  # Параметры для запроса
        if not os.path.exists(directory):
            os.makedirs(directory)

        try:
            connection = mysql.connector.connect(host=host, port=port, user=user, password=password, database=database)
            cursor = connection.cursor()
            cursor.execute(query, params)
            results = cursor.fetchall()  # Получаем все строки, соответствующие запросу
            if results:
                for index, row in enumerate(results):
                    # Определяем приписку на основе keywords
                    suffix = ''
                    row_string = ' '.join(map(str, row))
                    for keyword in keywords:
                        if keyword in row_string:
                            suffix = keyword
                            break
                    
                    # Формируем SQL-запрос для вставки
                    values = ', '.join([f"0x{value}" if i == 12 else (f"'{value}'" if isinstance(value, str) else str(value)) for i, value in enumerate(row)])
                    sql_insert = f"""INSERT INTO `sell_goods` (
    `acc_id`,
    `goods_id`,
    `name`,
    `type`,
    `count`,
    `price`,
    `icon`,
    `desc`,
    `rule`,
    `bp_id`,
    `publicity_period`,
    `expire_date`,
    `data`,
    `seller_id`,
    `seller_name`,
    `status`,
    `server_id`,
    `district_id`,
    `trading_volume`,
    `received`,
    `rule0`,
    `rule1`,
    `rule2`,
    `rule3`,
    `rule4`,
    `rule5`,
    `rule6`,
    `rule7`,
    `type0`,
    `type1`,
    `type2`,
    `type3`,
    `type4`,
    `type5`,
    `type6`,
    `type7`,
    `id`,
    `created_at`,
    `updated_at`,
    `deleted_at`
) VALUES (
    {values}
);
"""
                    # Запись в файл
                    filename = f"{directory}/{suffix}_{index}_insert.sql" if suffix else f"{directory}/insert_{index}.sql"
                    with open(filename, 'w', encoding='utf-8') as file:
                        file.write(sql_insert)  # Заполняем значения
                    print(f"Write to file: {filename}")

            else:
                print("Data not found.")
                messagebox.showinfo("Result", "Data not found.")
            messagebox.showinfo("Success", "Data from Sell_goods is received and written to the files in Save directory.")
        except mysql.connector.Error as err:
            print(f"Error: {err}")

            messagebox.showerror("Error", f"Error: {err}")
        finally:
            self.load_sql_files()
            if connection.is_connected():
                cursor.close()
                connection.close()

    def parse_sql(self):
        global ready
        ready = 0
        sql = self.sql_input.get("1.0", tk.END).strip()
        if not sql.startswith("INSERT INTO"):
            messagebox.showerror("Error", "Input SQL string must start with 'INSERT INTO'.")
            return
        try:
            insert_part = sql.split(" VALUES ")[0]
            values_part = sql.split(" VALUES ")[1].rstrip(");")

            fields = insert_part.split("(")[1].split(")")[0].split(",")
            values = re.findall(r"(?:(?<=,)|^)\s*(?:'([^']*)'|\"([^\"]*)\"|([^,]*))", values_part)

            for entry in self.entries:
                entry.destroy()
            self.entries.clear()
            self.fields.clear()
            for i, field in enumerate(fields):
                field = field.strip().strip('`')
                value = values[i][0] or values[i][1] or values[i][2].strip()

                label_text = field if field != "acc_id" else "acc_id(Steam)"
                label = tk.Label(self.scrollable_frame, text=label_text)
                label.grid(row=i, column=0, padx=2, pady=2, sticky='ew')

                value = value.strip("'()\n\t ") if field == "acc_id" else value

                entry = tk.Entry(self.scrollable_frame)
                entry.insert(0, value)
                entry.grid(row=i, column=1, padx=2, pady=2, sticky='ew')

                self.fields.append(field)
                self.entries.append(entry)
            ready = 1
            self.scrollable_frame.grid_columnconfigure(0, weight=1)
            self.scrollable_frame.grid_columnconfigure(1, weight=1)

        except Exception as e:
            messagebox.showerror("Error", f"Parsing error: {e}")

    def generate_sql(self):
        updated_values = []
        for entry in self.entries:
            value = entry.get().strip()
            
            if value.upper() == "NULL" or value.upper() == "NONE":
                updated_values.append("NULL")
                #updated_values.append("'3000-01-01 00:00:00'")
            elif value.startswith("0x") and all(c in "0123456789abcdefABCDEF" for c in value[2:]):
                updated_values.append(value)
            elif value.isdigit():
                updated_values.append(value)
            else:
                updated_values.append(f"'{value}'")

        updated_sql = f"INSERT INTO `sell_goods` (\n    " + ",\n    ".join([f"`{field}`" for field in self.fields]) + "\n) VALUES (\n    " + ",\n    ".join(updated_values) + "\n);"
        
        # Сохраняем текущее положение курсора
        cursor_position = self.updated_sql_output.index(tk.INSERT)
        
        self.updated_sql_output.delete("1.0", tk.END)
        
        self.updated_sql_output.insert(tk.END, updated_sql)
        
        self.updated_sql_output.mark_set("insert", cursor_position)
        self.updated_sql_output.see(cursor_position)


    def generate_hex_id(self, length=32):
        return ''.join(random.choices('0123456789ABCDEF', k=length))

    def fill_dates(self):
        date_values = {
            "id": "-1",
            "price": "9999999",
            "publicity_period": "2025-01-01 00:00:00",
            "expire_date": "2035-01-01 00:00:00",
            "created_at": "2025-01-01 00:00:00",
            "updated_at": "2035-01-01 00:00:00",
        }
        if not self.lockid:
            date_values["goods_id"] = self.generate_hex_id()
        
        for field in self.fields:
            if field in date_values:
                index = self.fields.index(field)
                if field == "id":
                    current_id = int(self.entries[index].get())
                    new_id = current_id + 10000
                    self.entries[index].delete(0, tk.END)
                    self.entries[index].insert(0, str(new_id))
                else:
                    self.entries[index].delete(0, tk.END)
                    self.entries[index].insert(0, date_values[field])

if __name__ == "__main__":
    root = tk.Tk()
    app = SQLInsertEditor(root)
    root.mainloop()
