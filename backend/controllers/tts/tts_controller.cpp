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
void TTSController::getResponseApiSythetice(const Rest::Request& request, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto body = request.body();
    auto json = TTSService::fetchApiSynthesize(body); // puedes adaptar el body si viene del frontend
    response.send(Http::Code::Ok, json);
}

void TTSController::getResponseFromVoices(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTSService::fetchApiVoices();
    response.send(Http::Code::Ok, json);
}
