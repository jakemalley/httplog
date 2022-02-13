package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func indexHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("indexHandler %s", req.URL)
	fmt.Fprintf(w, "{\"application\": \"httplog\"}")
}

func headersHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("headersHandler %s", req.URL)
	js, err := json.MarshalIndent(req.Header, "", "  ")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	fmt.Fprintf(w, "%s\n", js)
}

func healthHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("BEGIN healthHandler %s", req.URL)
	fmt.Fprintf(w, "{\"status\": \"UP\"}")
	log.Printf("END healthHandler %s", req.URL)
}

func main() {
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds | log.LUTC | log.Lshortfile)

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/probe", func(rw http.ResponseWriter, r *http.Request) {})
	http.HandleFunc("/headers", headersHandler)
	http.HandleFunc("/management/health", healthHandler)
	http.HandleFunc("/management/healthz", healthHandler)

	log.Println("httplog listening on :8888")
	http.ListenAndServe(":8888", nil)
}
