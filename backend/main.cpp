#include <pistache/net.h>
#include <pistache/http.h>
#include <pistache/peer.h>
#include <pistache/http_headers.h>
#include <pistache/cookie.h>
#include <pistache/router.h>
#include <pistache/endpoint.h>
#include <pistache/common.h>

#include <algorithm>
#include <vector>
#include <iostream>
#include <string>
#include <ctime>

using namespace Pistache;

class TongiServer {
public:
    explicit TongiServer(Address addr)
        : httpEndpoint(std::make_shared<Http::Endpoint>(addr))
    {
    }

    void init(size_t thr = 2) {
        auto opts = Http::Endpoint::options()
            .threads(static_cast<int>(thr));
        httpEndpoint->init(opts);
        setupRoutes();
    }

    void start() {
        httpEndpoint->setHandler(router.handler());
        httpEndpoint->serve();
    }

private:
    void setupRoutes() {
        using namespace Rest;

        Routes::Get(router, "/", Routes::bind(&TongiServer::doRoot, this));
        Routes::Get(router, "/hello", Routes::bind(&TongiServer::doHello, this));
        Routes::Get(router, "/api/health", Routes::bind(&TongiServer::doHealthCheck, this));
        Routes::Post(router, "/api/data", Routes::bind(&TongiServer::doPostData, this));
        Routes::Get(router, "/api/data", Routes::bind(&TongiServer::doGetData, this));
    }

    void doRoot(const Rest::Request& request, Http::ResponseWriter response) {
        response.headers()
            .add<Http::Header::AccessControlAllowOrigin>("*")
            .add<Http::Header::ContentType>(MIME(Text, Html));
        
        response.send(Http::Code::Ok, 
            "<html><body><h1>Tongi Backend Server</h1>"
            "<p>Server is running successfully!</p>"
            "<p>Available endpoints:</p>"
            "<ul>"
            "<li>GET / - This page</li>"
            "<li>GET /hello - Hello message</li>"
            "<li>GET /api/health - Health check</li>"
            "<li>GET /api/data - Get data</li>"
            "<li>POST /api/data - Post data</li>"
            "</ul></body></html>");
    }

    void doHello(const Rest::Request& request, Http::ResponseWriter response) {
        response.headers()
            .add<Http::Header::AccessControlAllowOrigin>("*")
            .add<Http::Header::ContentType>(MIME(Application, Json));
        
        response.send(Http::Code::Ok, "{\"message\": \"Hello from Tongi Backend!\"}");
    }

    void doHealthCheck(const Rest::Request& request, Http::ResponseWriter response) {
        response.headers()
            .add<Http::Header::AccessControlAllowOrigin>("*")
            .add<Http::Header::ContentType>(MIME(Application, Json));
        
        response.send(Http::Code::Ok, 
            "{\"status\": \"healthy\", \"service\": \"Tongi Backend\", \"timestamp\": \"" + 
            std::to_string(std::time(nullptr)) + "\"}");
    }

    void doPostData(const Rest::Request& request, Http::ResponseWriter response) {
        response.headers()
            .add<Http::Header::AccessControlAllowOrigin>("*")
            .add<Http::Header::ContentType>(MIME(Application, Json));
        
        auto body = request.body();
        std::cout << "Received POST data: " << body << std::endl;
        
        response.send(Http::Code::Ok, 
            "{\"message\": \"Data received successfully\", \"received_data\": \"" + body + "\"}");
    }

    void doGetData(const Rest::Request& request, Http::ResponseWriter response) {
        response.headers()
            .add<Http::Header::AccessControlAllowOrigin>("*")
            .add<Http::Header::ContentType>(MIME(Application, Json));
        
        response.send(Http::Code::Ok, 
            "{\"data\": [\"item1\", \"item2\", \"item3\"], \"count\": 3}");
    }

    std::shared_ptr<Http::Endpoint> httpEndpoint;
    Rest::Router router;
};

int main(int argc, char *argv[]) {
    Port port(9080);
    int thr = 2;

    if (argc >= 2) {
        port = static_cast<uint16_t>(std::stol(argv[1]));

        if (argc == 3)
            thr = std::stoi(argv[2]);
    }

    Address addr(Ipv4::any(), port);

    std::cout << "Starting Tongi Backend Server..." << std::endl;
    std::cout << "Cores = " << hardware_concurrency() << std::endl;
    std::cout << "Using " << thr << " threads" << std::endl;
    std::cout << "Listening on port " << port << std::endl;

    TongiServer server(addr);

    server.init(thr);
    server.start();

    return 0;
}
