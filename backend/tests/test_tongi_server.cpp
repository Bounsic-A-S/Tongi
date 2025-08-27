#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <pistache/net.h>
#include <pistache/http.h>
#include <pistache/client.h>
#include <thread>
#include <chrono>
#include <memory>
#include <future>
#include <json/json.h>

// Include the server code (we'll need to refactor main.cpp to separate the class)
// For now, we'll copy the TongiServer class definition here
#include <pistache/router.h>
#include <pistache/endpoint.h>

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
        httpEndpoint->serveThreaded();
    }

    void stop() {
        httpEndpoint->shutdown();
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

class TongiServerTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Use a different port for testing to avoid conflicts
        testPort = Port(9081);
        Address addr(Ipv4::any(), testPort);
        server = std::make_unique<TongiServer>(addr);
        server->init(1); // Use single thread for testing
        
        // Start server in a separate thread
        serverThread = std::thread([this]() {
            server->start();
        });
        
        // Give server time to start
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    void TearDown() override {
        server->stop();
        if (serverThread.joinable()) {
            serverThread.join();
        }
    }

    Port testPort;
    std::unique_ptr<TongiServer> server;
    std::thread serverThread;
};

// Test the root endpoint
TEST_F(TongiServerTest, RootEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/").send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    ASSERT_TRUE(response.body().find("Tongi Backend Server") != std::string::npos);
    ASSERT_TRUE(response.body().find("<html>") != std::string::npos);
    
    client.shutdown();
}

// Test the hello endpoint
TEST_F(TongiServerTest, HelloEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/hello").send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    
    // Parse JSON response
    Json::Value root;
    Json::Reader reader;
    bool parsingSuccessful = reader.parse(response.body(), root);
    
    ASSERT_TRUE(parsingSuccessful);
    ASSERT_TRUE(root.isMember("message"));
    ASSERT_EQ(root["message"].asString(), "Hello from Tongi Backend!");
    
    client.shutdown();
}

// Test the health check endpoint
TEST_F(TongiServerTest, HealthCheckEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/api/health").send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    
    // Parse JSON response
    Json::Value root;
    Json::Reader reader;
    bool parsingSuccessful = reader.parse(response.body(), root);
    
    ASSERT_TRUE(parsingSuccessful);
    ASSERT_TRUE(root.isMember("status"));
    ASSERT_TRUE(root.isMember("service"));
    ASSERT_TRUE(root.isMember("timestamp"));
    ASSERT_EQ(root["status"].asString(), "healthy");
    ASSERT_EQ(root["service"].asString(), "Tongi Backend");
    
    client.shutdown();
}

// Test GET /api/data endpoint
TEST_F(TongiServerTest, GetDataEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/api/data").send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    
    // Parse JSON response
    Json::Value root;
    Json::Reader reader;
    bool parsingSuccessful = reader.parse(response.body(), root);
    
    ASSERT_TRUE(parsingSuccessful);
    ASSERT_TRUE(root.isMember("data"));
    ASSERT_TRUE(root.isMember("count"));
    ASSERT_EQ(root["count"].asInt(), 3);
    ASSERT_TRUE(root["data"].isArray());
    ASSERT_EQ(root["data"].size(), 3);
    
    client.shutdown();
}

// Test POST /api/data endpoint
TEST_F(TongiServerTest, PostDataEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    std::string testData = "{\"test\": \"data\", \"number\": 42}";
    
    auto request = client.post("http://localhost:9081/api/data");
    request.body(testData);
    auto response = request.send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    
    // Parse JSON response
    Json::Value root;
    Json::Reader reader;
    bool parsingSuccessful = reader.parse(response.body(), root);
    
    ASSERT_TRUE(parsingSuccessful);
    ASSERT_TRUE(root.isMember("message"));
    ASSERT_TRUE(root.isMember("received_data"));
    ASSERT_EQ(root["message"].asString(), "Data received successfully");
    ASSERT_EQ(root["received_data"].asString(), testData);
    
    client.shutdown();
}

// Test CORS headers are present
TEST_F(TongiServerTest, CorsHeadersPresent) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/hello").send();
    
    ASSERT_EQ(response.code(), Http::Code::Ok);
    
    // Check for CORS header
    auto headers = response.headers();
    bool corsHeaderFound = false;
    
    for (const auto& header : headers.list()) {
        if (header->name() == "Access-Control-Allow-Origin") {
            corsHeaderFound = true;
            ASSERT_EQ(header->value(), "*");
            break;
        }
    }
    
    ASSERT_TRUE(corsHeaderFound);
    
    client.shutdown();
}

// Test invalid endpoint returns 404
TEST_F(TongiServerTest, InvalidEndpoint) {
    Http::Client client;
    
    auto opts = Http::Client::options()
        .threads(1)
        .maxConnectionsPerHost(1);
    client.init(opts);

    auto response = client.get("http://localhost:9081/nonexistent").send();
    
    ASSERT_EQ(response.code(), Http::Code::Not_Found);
    
    client.shutdown();
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
