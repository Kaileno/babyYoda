public class ExternalCallout {
    public  final string  CONTENT_TYPE_JSON='application/json';
    public  final string BEARER='Bearer ';
    public 	final static string EMPTY='';
    public 	enum HTTP_METHOD { GET, POST, DEL, PUT, PATCH }
    public 	enum AUTH_TYPE { BASIC, NAMED_CREDENTIAL }
    
    
    private static String toUrlParams(Map<String,String> params){
        List<String> paramsList = new List<String>();
        for(String k :params.keySet()){
            string val=params.get(k);
            paramsList.add(k + '=' + (val!=null?EncodingUtil.URLENCODE(params.get(k),'UTF-8'):''));
        }
        return String.join(paramsList, '&');
    }
   
    private static String getEndpoint(String endpoint, Map<String, String> urlParams){
        if(urlParams != NULL && !urlParams.isEmpty()){
            endpoint = endpoint + '?' + toUrlParams(urlParams);
        }
        return endpoint;
    }
    
    private static String createBody(Map<String, String> urlParams){
        if(urlParams != NULL && !urlParams.isEmpty()){
           return toUrlParams(urlParams);
        }
        return EMPTY;
    }
    
    private void setAuthorizationHeader(HttpRequest httpRequest,Map<String, String> headers)
    {
        if(headers!=null && headers.size()>0){
            for(String key :headers.keySet()){
                string val=headers.get(key);
                httpRequest.setHeader(key,val);
            }
        }
    }
    
    private static boolean checkHeader(HttpRequest request,string contType)
    {
        string contentType = request.getHeader(contType);
        return string.isNotBlank(contentType);
    }
    
    private void setNamedCredential(HttpRequest httpRequest, string namedCredential, Map<String, String> ncParams, HTTP_METHOD method)
    {
        if(string.isNotBlank(namedCredential))
        {
            String jsonBody = '';
           
            if(method==HTTP_METHOD.GET)
            {
                string url=getEndpoint('callout:'+namedCredential,ncParams);
               	HttpRequest.setEndpoint(url);
            }
            if(method==HTTP_METHOD.POST)
            {
                jsonBody=JSON.serialize(ncParams);
                boolean isContentTypeSet=checkHeader(httpRequest,'Content-Type');
                system.debug('isContentTypeSet:'+isContentTypeSet);
                if(!isContentTypeSet)
                {
                    httpRequest.setHeader('Content-Type',CONTENT_TYPE_JSON);
                    httpRequest.setHeader('Content-Length',jsonBody.length()+'');
                }
                HttpRequest.setEndpoint('callout:'+namedCredential);
                httpRequest.setCompressed(true);
                httpRequest.setBody(jsonBody);
            }
        } 
    }
    
    private AUTH_TYPE authType(string urlornc)
    {
        AUTH_TYPE authType;
        //Check url is having named credential or proper url 
        try
        {
            URL urltest = new URL(urlornc);
            authType=AUTH_TYPE.BASIC;
        }
        catch(System.StringException e)
        {
            authType=AUTH_TYPE.NAMED_CREDENTIAL;
        }
        return authType;
    } 
    
    public HttpResponse get(string url, Map<String, String> params)
    {
        return call(authType(url), HTTP_METHOD.GET, url, params, null);
    }
    public HttpResponse get(string url)
    {
        return call(authType(url), HTTP_METHOD.GET, url, null, null);
    }
    public HttpResponse get(string urlornc, Map<String, String> params, Map<String, String> headers)
    {
        return call(authType(urlornc), HTTP_METHOD.GET, urlornc, params, headers);
    }
   	
    public HttpResponse post(string url, Map<String, String> headers, Map<String, String> params)
    {
       return call(authType(url), HTTP_METHOD.POST, url, headers, params);
    }
    
    public HttpResponse del(string url, Map<String, String> headers, Map<String, String> params)
    {
       return call(authType(url), HTTP_METHOD.DEL, url, headers, params);
    }
    public HttpResponse call(AUTH_TYPE authType, HTTP_METHOD method, string namedCredOrEndpoint, Map<String, String> ncParams, Map<String, String> headers)
    {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod(method.name()=='DEL'?'DELETE':method.name());
        httpRequest.setTimeout(120000);
        if(authType==AUTH_TYPE.BASIC)
        {
            setAuthorizationHeader(httpRequest,headers);
            system.debug('ncParams:'+ncParams);
            if(ncParams!=null && method==HTTP_METHOD.GET)
            {
                //namedCredential is url for basic cases
                namedCredOrEndpoint=getEndpoint(namedCredOrEndpoint,ncParams);
            }
           	httpRequest.setEndpoint(namedCredOrEndpoint);
        }
        if(authType==AUTH_TYPE.NAMED_CREDENTIAL)
        {
            setAuthorizationHeader(httpRequest,headers);
            string url=getEndpoint('callout:'+namedCredOrEndpoint,ncParams);
            if(method==HTTP_METHOD.GET)
            {
               httpRequest.setEndpoint(url);
            }
            setNamedCredential(httpRequest, namedCredOrEndpoint, ncParams, method);            
        }
        
        if(method==HTTP_METHOD.POST || method==HTTP_METHOD.PATCH)
        {
            httpRequest.setBody(createBody(ncParams));
            httpRequest.setEndpoint(namedCredOrEndpoint);            
        }
        system.debug('namedCredOrEndpoint:'+namedCredOrEndpoint);   
        system.debug('Body:'+createBody(ncParams));       
        return !Test.isRunningTest() ? new Http().send(httpRequest) : null;
    }
}