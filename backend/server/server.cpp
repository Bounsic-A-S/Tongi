#include "server.h"
#include <pistache/http.h>
#include <pistache/net.h>
#include <pistache/http_headers.h>

#include "../controllers/health/health_controller.h"
#include "../controllers/data/data_controller.h"
#include "../controllers/ttt/ttt_controller.h"


TongiServer::TongiServer(Pistache::Address addr)
    : httpEndpoint(std::make_shared<Pistache::Http::Endpoint>(addr)) {}

void TongiServer::init(size_t thr) {
    auto opts = Pistache::Http::Endpoint::options().threads(static_cast<int>(thr));
    httpEndpoint->init(opts);
    setupRoutes();
}

void TongiServer::start() {
    httpEndpoint->setHandler(router.handler());
    httpEndpoint->serve();
}

void TongiServer::stop() {
    httpEndpoint->shutdown();
}

void TongiServer::setupRoutes() {
    using namespace Pistache;

    Rest::Routes::Get(router, "/", Rest::Routes::bind(&HealthController::root));
    Rest::Routes::Get(router, "/hello", Rest::Routes::bind(&HealthController::hello));
    Rest::Routes::Get(router, "/api/health", Rest::Routes::bind(&HealthController::checkHealth));
    // data test
    Rest::Routes::Get(router, "/api/data", Rest::Routes::bind(&DataController::getData));
    Rest::Routes::Post(router, "/api/data", Rest::Routes::bind(&DataController::postData));
    // ttt
    Rest::Routes::Get(router, "/api/ttt/health", Rest::Routes::bind(&TTTController::getHealth));
    Rest::Routes::Post(router, "/api/ttt/translate", Rest::Routes::bind(&TTTController::TextTranslation));

}
