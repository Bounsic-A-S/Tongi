#include "stt_controller.h"
#include <pistache/http_headers.h>
#include "../../services/stt/stt_service.h"

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}
void STTController::getResponseFromMicroService(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = STTService::fetchApiRoot();
    response.send(Http::Code::Ok, json);
}
void STTController::getHealth(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = STTService::fetchApiHealth();
    response.send(Http::Code::Ok, json);
}