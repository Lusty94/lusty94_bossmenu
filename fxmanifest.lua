fx_version 'cerulean'

game 'gta5'

author 'Lusty94'

name 'lusty94_towing'

description 'Towing Script For For QB Core'

version '1.0.0'

lua54 'yes'

client_script {
    'client/towing_client.lua',
}


server_scripts { 
    'server/towing_server.lua',
    '@oxmysql/lib/MySQL.lua',
}


shared_scripts { 
    'shared/config.lua',
    '@ox_lib/init.lua'
}

escrow_ignore {
    'shared/**.lua',
    'client/**.lua',
    'server/**.lua',
}


--remove this if you are not using the ramps from bzzz
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_ramps.ytyp'