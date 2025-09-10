#include <gtest/gtest.h>
#include <pistache/client.h>
#include "../server/server.h"
#include <thread>
#include <chrono>
#include <memory>
#include <future>


using namespace Pistache;

class IntegrationTest : public ::testing::Test {
protected:
    void SetUp() override {
        Address addr(Ipv4::loopback(), Port(9081)); // testing in another port
        server = std::make_shared<TongiServer>(addr);
        server->init(1);

        serverThread = std::thread([&]() {
            server->start();
        });
        std::this_thread::sleep_for(std::chrono::milliseconds(200)); // ewait for the server to run
    }

    void TearDown() override {
        server->stop(); // shutdown for turn off the server (carvajal don't kill me)
        if (serverThread.joinable()) serverThread.join();
    }

    std::shared_ptr<TongiServer> server;
    std::thread serverThread;
};

TEST_F(IntegrationTest, HealthCheckReturnsHealthy) {
    Http::Experimental::Client client;
    auto rb = client.get("http://localhost:9081/api/health"); // testing the endpoint!!

    std::promise<Http::Response> prom;
    auto fut = prom.get_future();

    rb.send()
        .then([&](Http::Response resp) {
            prom.set_value(std::move(resp));
        },
        [&](std::exception_ptr exc) {
            try {
                std::rethrow_exception(exc);
            } catch (const std::exception& e) {
                FAIL() << "Request failed: " << e.what();
            }
        });

    auto response = fut.get();  // bloquea hasta que llega la respuesta

    ASSERT_EQ(response.code(), Http::Code::Ok);
    EXPECT_NE(response.body().find("healthy"), std::string::npos);
}

