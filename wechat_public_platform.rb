require "wechat_public_platform/version"
require "open-uri" 

module WechatPublicPlatform
  # Your code goes here...
  class << self
	  def get_openid code,app_id,app_secret
	    url = 'https://api.weixin.qq.com/sns/oauth2/access_token?appid='+app_id+'&secret='+app_secret+'&code='+code+'&grant_type=authorization_code'
	    result_json = JSON.parse ruby_get(url)
	    result_json['openid']
	  end

	  def get_access_token app_id,app_secret
	    url = 'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid='+app_id+'&secret='+app_secret
	    result_json = JSON.parse ruby_get(url)
	    result_json['access_token']
	  end

	  def get_jsapi_ticket access_token
	    url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{access_token}&type=jsapi"
	    result_json = JSON.parse ruby_get(url)
	    result_json['ticket']   
	  end

	  def wechat_js_signature jsapi_ticket,url,timestamp,noncestr
	    string1 = "jsapi_ticket=#{jsapi_ticket}&noncestr=#{noncestr}&timestamp=#{timestamp}&url=#{url}"
	    Digest::SHA1.hexdigest(string1)
	  end

	  def get_user_info access_token, openid
	    url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
	    result_json = JSON.parse ruby_get(url)
	  end

	  private

	  def ruby_get url
	  	result = ""
	    open(url) do |http|
	      result = http.read
	    end
	    result
	  end
	end
end
