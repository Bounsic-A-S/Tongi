#include "ttt_controller.h"
#include <pistache/http_headers.h>
#include "../../services/ttt/ttt_service.h"

using namespace Pistache;

static void setJsonHeaders(Http::ResponseWriter& response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
}

void TTTController::getTextTranslation(const Rest::Request&, Http::ResponseWriter response) {
    setJsonHeaders(response);
    auto json = TTTService::fetchApiData();
    response.send(Http::Code::Ok, json);
}
