# Webwidgets
Web widgets for GeneSC tools

## Wechat API 

install:
$ gem install wechat_public_platform

use:
```Bash
require "wechat_public_platform"
```

openid:
```Bash
WechatPublicPlatform.get_openid code,app_id,app_secret
```

access_token:
```Bash
WechatPublicPlatform.get_access_token app_id,app_secret
```

jsapi_ticket:
```Bash
WechatPublicPlatform.get_jsapi_ticket access_token
```

wechat_js_signature:
```Bash
WechatPublicPlatform.wechat_js_signature jsapi_ticket,url,timestamp,noncestr
```

user_info:
```Bash
WechatPublicPlatform.get_user_info access_token, openid
```

