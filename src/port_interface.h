#ifndef PORT_INTERFACE_H
#define PORT_INTERFACE_H

#ifdef DEBUG
#define debug(...) do { printf("DBG: "); printf(__VA_ARGS__); printf("\r\n"); fflush(stdout); } while (0)
#else
#define debug(...)
#endif

#define reply_ok() do { printf("OK\r\n"); fflush(stdout); } while(0)

#define reply_ok_payload(...) do { printf("OK: "); printf(__VA_ARGS__); printf("\r\n"); fflush(stdout); } while (0)

#define reply_error(...) do { printf("ERR: "); printf(__VA_ARGS__); printf("\r\n"); fflush(stdout); } while (0)

#endif // PORT_INTERFACE_H
