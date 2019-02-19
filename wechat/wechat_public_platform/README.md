
install:
$ gem install wechat_public_platform

use:
# require "wechat_public_platform"

openid:
# WechatPublicPlatform.get_openid code,app_id,app_secret

access_token:
# WechatPublicPlatform.get_access_token app_id,app_secret

jsapi_ticket:
# WechatPublicPlatform.get_jsapi_ticket access_token

wechat_js_signature:
# WechatPublicPlatform.wechat_js_signature jsapi_ticket,url,timestamp,noncestr

user_info:
# WechatPublicPlatform.get_user_info access_token, openid