#include "server/server.h"
#include <iostream>

int main(int argc, char* argv[]) {
    using namespace Pistache;

    Port port(9080);
    int thr = 2;

    if (argc >= 2) {
        port = static_cast<uint16_t>(std::stol(argv[1]));
        if (argc >= 3) thr = std::stoi(argv[2]);
    }

    Address addr(Ipv4::any(), port);

    std::cout << "Starting Tongi Backend Server...\n";
    std::cout << "Cores = " << hardware_concurrency() << "\n";
    std::cout << "Using " << thr << " threads\n";
    std::cout << "Listening on port " << port << "\n";

    TongiServer server(addr);
    server.init(thr);
    server.start();

    return 0;
}
