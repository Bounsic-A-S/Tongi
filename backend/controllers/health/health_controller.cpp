#include "health_controller.h"
#include <pistache/http_headers.h>
#include <ctime>
#include <string>

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}

void HealthController::root(const Rest::Request&, Http::ResponseWriter response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Text, Html));

    response.send(Http::Code::Ok,
        "<html><body><h1>Tongi Backend Server</h1>"
        "<p>Server is running successfully!</p>"
        "<ul>"
        "<li>GET /hello</li>"
        "<li>GET /api/health</li>"
        "<li>GET /api/data</li>"
        "<li>POST /api/data</li>"
        "</ul></body></html>");
}

void HealthController::hello(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    response.send(Http::Code::Ok, R"({"message":"Hello from Tongi Backend!"})");
}

void HealthController::checkHealth(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto ts = std::to_string(std::time(nullptr));
    std::string payload = std::string("{\"status\":\"healthy\",\"service\":\"Tongi Backend\",\"timestamp\":\"") 
                    + ts + "\"}";
    response.send(Http::Code::Ok, payload);
}
