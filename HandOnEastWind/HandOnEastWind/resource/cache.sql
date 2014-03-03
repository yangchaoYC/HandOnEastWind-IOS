CREATE TABLE news (id INTEGER PRIMARY KEY AUTOINCREMENT, nid INTEGER, node_created NUMERIC, node_title TEXT, field_thumbnails TEXT, field_channel TEXT, field_newsfrom TEXT, field_summary TEXT, body_1 TEXT, body_2 TEXT);



CREATE TABLE "update_log" (id INTEGER PRIMARY KEY AUTOINCREMENT, channel_id INTEGER, channel_name TEXT, update_time NUMERIC);



