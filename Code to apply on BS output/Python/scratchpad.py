import requests
call = 'https://edgeryders.eu/t/6343.json'
topic = requests.get(call).json()
for post in topic['post_stream']['posts']:
  if post['reply_to_post_number'] != None:
    continue
  else:
    if 'reply_to_user' in post:
      print post['post_number']

print topic['post_stream']['posts'][4]['reply_to_post_number']
print type(topic['post_stream']['posts'][4]['reply_to_post_number'])
