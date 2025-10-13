-- Postgres dump and file rotation

local db_name = "brent"
local dump_dir = "/var/backups/postgres"
local keep_count = 10

os.execute("mkdir -p " .. dump_dir)

local timestamp = os.date("%Y-%m-%d_%H%M%S")
local dump_file = string.format("%s/%s_%s.dump", dump_dir, db_name, timestamp)

print("Dumping database '" .. db_name .. "' to " .. dump_file)
local dump_command = string.format("pg_dump -Fc -f %s %s", dump_file, db_name)
local dump_success = os.execute(dump_command)

if not dump_success then
    error("pg_dump failed to create the backup file.")
end
print("Database dumped.")

print("Rotating old backup files...")

local files = {}
local file_list_command = string.format("ls -t %s/%s_*.dump", dump_dir, db_name)
local handle = io.popen(file_list_command)

if not handle then
    error("ERROR: Could not list files in directory...")
end

for filename in handle:lines() do
    table.insert(files, filename)
end
handle:close()

if #files > keep_count then
    for i = keep_count + 1, #files do
        local file_to_delete = files[i]
        print("Deleting old backup: " .. file_to_delete)
        os.remove(file_to_delete)
    end
end

print("Rotation complete. Retained " .. math.min(#files, keep_count) .. " files.")

