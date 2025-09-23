#include "ttt_controller.h"
#include <pistache/http_headers.h>
#include "../../services/ttt/ttt_service.h"

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}
void TTTController::getResponseFromMicroService(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTTService::fetchApiRoot();
    response.send(Http::Code::Ok, json);
}
void TTTController::getHealth(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTTService::fetchApiHealth();
    response.send(Http::Code::Ok, json);
}
void TTTController::TextTranslation(const Rest::Request& request, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto body = request.body();
    auto json = TTTService::fetchApiTranslation(body);
    response.send(Http::Code::Ok, json);
}
void TTTController::getTasks(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTTService::fetchApiTasks();
    response.send(Http::Code::Ok, json);
}
void TTTController::getLanguagesAvailable(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTTService::fetchApiLanguages();
    response.send(Http::Code::Ok, json);
}