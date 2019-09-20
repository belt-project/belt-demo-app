package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

type giphyResponse struct {
	Data struct {
		Images struct {
			DownsizedStill struct {
				URL string `json:"url"`
			} `json:"downsized_still"`
		} `json:"images"`
	} `json:"data"`
}

func getGIF(key string) (string, error) {
	client := &http.Client{}

	url := fmt.Sprintf("https://api.giphy.com/v1/gifs/random?api_key=%s&tag=&rating=G", key)

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}

	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", errors.New("http status code not OK")
	}

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	defer resp.Body.Close()

	response := &giphyResponse{}
	if err := json.Unmarshal(data, response); err != nil {
		return "", err
	}

	return response.Data.Images.DownsizedStill.URL, nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	gifURL, err := getGIF(os.Getenv("GIPHY_TOKEN"))
	if err != nil {
		log.Printf("error: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Add("Content-Type", "text/html")
	fmt.Fprintf(w, `<html><img src="%s"></html>`, gifURL)
}

func main() {
	http.HandleFunc("/", handler)

	log.Println("Starting server...")
	log.Fatalln(http.ListenAndServe(":1234", nil))
}
