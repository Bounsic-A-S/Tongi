#include "tts_controller.h"
#include <pistache/http_headers.h>
#include "../../services/tts/tts_service.h"

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}
void TTSController::getResponseFromMicroService(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTSService::fetchApiRoot();
    response.send(Http::Code::Ok, json);
}
void TTSController::getHealth(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTSService::fetchApiHealth();
    response.send(Http::Code::Ok, json);
}