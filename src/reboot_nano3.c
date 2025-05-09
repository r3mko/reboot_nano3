/*
 * reboot_nano3.c
 *
 * A Linux daemon that checks system uptime every -i minutes,
 * and reboots if uptime exceeds -d days.
 *
 * Usage: uptime_reboot_daemon [-i interval_minutes] [-d max_days] [-D] [-h]
 *   -i <minutes>   Polling interval in minutes (default: 60)
 *   -d <days>      Uptime threshold in days (default: 21)
 *   -D             Enable debug logging to stderr
 *   -h             Show help and exit
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/reboot.h>
#include <linux/reboot.h>
#include <string.h>
#include <errno.h>
#include <getopt.h>
#include <time.h>

static int interval_minutes = 60;
static int max_days = 21;

static int debug_mode = 0;

void print_usage(const char *prog) {
    fprintf(stderr,
        "Usage: %s [-i interval_minutes] [-d max_days] [-D] [-h]\n"
        "  -i <minutes>   Polling interval in minutes (default: %d)\n"
        "  -d <days>      Uptime threshold in days (default: %d)\n"
        "  -D             Enable debug logging\n"
        "  -h             Show this help and exit\n",
        prog, interval_minutes, max_days);
}

void daemonize() {
    pid_t pid = fork();
    if (pid < 0) exit(EXIT_FAILURE);
    if (pid > 0) exit(EXIT_SUCCESS);
    if (setsid() < 0) exit(EXIT_FAILURE);
    (void)signal(SIGCHLD, SIG_IGN);
    (void)signal(SIGHUP, SIG_IGN);
    pid = fork();
    if (pid < 0) exit(EXIT_FAILURE);
    if (pid > 0) exit(EXIT_SUCCESS);
    umask(0);
    (void)chdir("/");
    for (int fd = sysconf(_SC_OPEN_MAX); fd >= 0; fd--) close(fd);
}

long read_uptime_seconds() {
    FILE *f = fopen("/proc/uptime", "r");
    if (!f) {
        if (debug_mode) perror("fopen /proc/uptime");
        return -1;
    }
    double up = 0;
    if (fscanf(f, "%lf", &up) != 1) {
        if (debug_mode) fprintf(stderr, "Failed to parse uptime\n");
        fclose(f);
        return -1;
    }
    fclose(f);
    return (long)up;
}

int main(int argc, char *argv[]) {
    int opt;
    while ((opt = getopt(argc, argv, "i:d:Dh")) != -1) {
        switch (opt) {
            case 'i': interval_minutes = atoi(optarg); break;
            case 'd': max_days = atoi(optarg); break;
            case 'D': debug_mode = 1; break;
            case 'h': print_usage(argv[0]); return 0;
            default: print_usage(argv[0]); return 1;
        }
    }

    if (debug_mode) {
        fprintf(stderr, "Starting daemon:\nCheck interval = %d min, max uptime = %d days\n",
        interval_minutes, max_days);
    } else {
        fprintf(stderr, "Starting daemon:\nCheck interval = %d min, max uptime = %d days\nRun `%s -h` for help.\n",
        interval_minutes, max_days, argv[0]);
        daemonize();
    }

    while (1) {
        long up_sec = read_uptime_seconds();
        if (up_sec < 0) {
            if (debug_mode) fprintf(stderr, "Error reading uptime, retrying in %d minutes\n", interval_minutes);
        } else {
            double up_days = up_sec / 86400.0;
            if (debug_mode) fprintf(stderr, "Current uptime: %.2f days\n", up_days);
            if (up_days > max_days) {
                if (debug_mode) fprintf(stderr, "Uptime exceeded %d days, rebooting now...\n", max_days);
                sync();
                reboot(RB_AUTOBOOT);
                if (debug_mode) perror("reboot");
            }
        }
        sleep(interval_minutes * 60);
    }

    return 0;
}
