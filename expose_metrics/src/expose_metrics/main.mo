import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prim "mo:prim";
import StableMemory "mo:base/ExperimentalStableMemory";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor ExposeMetrics {

  let API_KEY = "MySecretKey";
  let REQUIRE_AUTHZ = false;

  type HeaderField = (Text, Text);

  type HttpResponse = {
    status_code: Nat16;
    headers: [HeaderField];
    body: Blob;
  };
  
  type HttpRequest = {
    method: Text;
    url: Text;
    headers: [HeaderField];
    body: Blob;
  };

  let permission_denied: HttpResponse = {
    status_code = 403;
    headers = [];
    body = "";
  };
  
  public query func http_request(req : HttpRequest) : async HttpResponse {
    // Strip query params and get only path
    let ?path = Text.split(req.url, #char '?').next();
    Debug.print(req.url);
    Debug.print(path);
    switch (req.method, path) {
      // Endpoint that serves metrics to be consumed with Prometheseus
      case ("GET", "/metrics") {
        Debug.print("GET: /metrics");
        
        // Handle authz
        if REQUIRE_AUTHZ {
          let key = get_api_key(req.headers);
          switch(key) {
            case(null) return permission_denied;
            case(?v) let key = v;
          };
          if (key != "Bearer " # API_KEY) {
            return permission_denied;
          };
        };

        // We'll arrive here only if authz was successful
        let m = metrics();
        Debug.print(m);
        {
          status_code =  200;
          headers = [ ("content-type", "text/plain") ];
          body =  Text.encodeUtf8(m);
        }
      };
      case _ {
        Debug.print("Invalid request");
        {
          status_code = 400;
          headers = [];
          body = "Invalid request";
        }
      };
    } 
  };

  // Returns the api key from the authz header
  func get_api_key(headers: [HeaderField]) : ?Text {
    let key = "";
    let authz_header : ?HeaderField = Array.find(headers, func((header, val): (Text, Text)) : Bool { header == "authorization" });
      switch authz_header {
        case(null) null;
        case(?header) {
          ?header.1;
        };
      };
  };

  // Returns a set of metrics encoded in Prometheus text-based exposition format
  // https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
  // More info on the specific metrics can be found in the following forum threads:
  // https://forum.dfinity.org/t/motoko-get-canisters-sizes-limits/2092
  // https://forum.dfinity.org/t/motoko-array-memory/5324/4
  func metrics() : Text {

    // Prometheus expects timestamps in ms. Time.now() returns ns.
    let timestamp = Int.toText(Time.now()/1000000);

    "# HELP balance The current balance in cycles \n" #
    "balance{} " # Nat.toText(Cycles.balance()) # " " # timestamp # "\n" #
    "# HELP heap_size The current size of the wasm heap in pages of 64KiB \n" #
    "heap_size{} " # Nat.toText(Prim.rts_heap_size()) # " " # timestamp # "\n" #
    "# HELP mem_size The current size of the wasm memory in pages of 64KiB \n" #
    "mem_size{} " # Nat.toText(Prim.rts_memory_size()) # " " # timestamp # "\n" #
    "# HELP mem_size The current size of the stable memory in pages of 64KiB \n" #
    "stable_mem_size{} " # Nat64.toText(StableMemory.size()) # " " # timestamp;

  };

};
