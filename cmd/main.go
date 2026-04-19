package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/canopy-network/canopy/app"
	"github.com/canopy-network/canopy/lib/logger"
)

var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
	// Parse command-line flags
	configPath := flag.String("config", "", "path to config file (default: $HOME/.canopy/config.json)")
	dataDir := flag.String("data-dir", "", "path to data directory (default: $HOME/.canopy)")
	logLevel := flag.String("log-level", "info", "log level: debug, info, warn, error")
	showVersion := flag.Bool("version", false, "print version information and exit")
	flag.Parse()

	if *showVersion {
		fmt.Printf("canopy version %s (commit: %s, built: %s)\n", version, commit, date)
		os.Exit(0)
	}

	// Initialize logger
	log := logger.New(*logLevel)
	log.Infof("Starting canopy node version %s", version)

	// Build application config
	cfg, err := app.LoadConfig(*configPath, *dataDir)
	if err != nil {
		log.Errorf("Failed to load config: %v", err)
		os.Exit(1)
	}

	// Initialize and start the application
	application, err := app.New(cfg, log)
	if err != nil {
		log.Errorf("Failed to initialize application: %v", err)
		os.Exit(1)
	}

	if err := application.Start(); err != nil {
		log.Errorf("Failed to start application: %v", err)
		os.Exit(1)
	}

	// Wait for interrupt signal for graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("Shutting down canopy node...")
	if err := application.Stop(); err != nil {
		log.Errorf("Error during shutdown: %v", err)
		os.Exit(1)
	}
	log.Info("Node stopped successfully")
}
