using System.Web.Http;

namespace ERPFinanceiro.Api
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            GlobalConfiguration.Configure(Startup.Configure);
        }
    }
}
