#include "data_controller.h"
#include <pistache/http_headers.h>
#include "../services/data/data_service.h"

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}

void DataController::getData(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = DataService::fetchData();
    response.send(Http::Code::Ok, json);
}

void DataController::postData(const Rest::Request& request, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto body = request.body();
    auto json = DataService::saveData(body);
    response.send(Http::Code::Ok, json);
}
