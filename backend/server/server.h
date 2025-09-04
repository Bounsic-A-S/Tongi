#ifndef TONGI_SERVER_H
#define TONGI_SERVER_H

#include <pistache/endpoint.h>
#include <pistache/router.h>
#include <memory>

class TongiServer {
public:
    explicit TongiServer(Pistache::Address addr);
    void init(size_t thr = 2);
    void start();

private:
    void setupRoutes();

    std::shared_ptr<Pistache::Http::Endpoint> httpEndpoint;
    Pistache::Rest::Router router;
};

#endif
