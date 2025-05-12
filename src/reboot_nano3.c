/*
 * reboot_nano3.c
 *
 * A Linux daemon that checks system uptime every -i minutes,
 * and reboots if uptime exceeds -d days.
 *
 * Usage: uptime_reboot_daemon [-i interval_minutes] [-d max_days] [-D] [-v] [-h]
 *
 *   -i <minutes>   Polling interval in minutes (default: 60)
 *   -d <days>      Uptime threshold in days (default: 21)
 *   -D             Enable debug logging
 *   -v             Show version and exit
 *   -h             Show help and exit
 */

#include <stdio.h>        /* fprintf, perror, FILE* */
#include <stdlib.h>       /* exit, atoi, EXIT_… */
#include <unistd.h>       /* fork, setsid, chdir, close, sysconf, getopt, geteuid, sleep */
#include <sys/types.h>    /* pid_t */
#include <sys/stat.h>     /* umask */
#include <signal.h>       /* signal, SIGCHLD, SIGHUP */
#include <sys/reboot.h>   /* reboot(2) prototype */
#include <linux/reboot.h> /* RB_AUTOBOOT */
#include <errno.h>        /* errno (for perror) */

#define VERSION "0.3"

static int interval_minutes = 60;
static int max_days = 21;

static int debug_mode = 0;

void print_usage(const char *prog) {
    fprintf(stderr,
        "%s v%s\n\n"
        "Usage: %s [-i interval_minutes] [-d max_days] [-D] [-v] [-h]\n\n"
        "  -i <minutes>   Polling interval in minutes (default: %d)\n"
        "  -d <days>      Uptime threshold in days (default: %d)\n"
        "  -D             Enable debug logging\n"
        "  -v             Show version and exit\n"
        "  -h             Show this help and exit\n",
        prog, VERSION, prog, interval_minutes, max_days);
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
    while ((opt = getopt(argc, argv, "i:d:Dvh")) != -1) {
        switch (opt) {
            case 'i': interval_minutes = atoi(optarg); break;
            case 'd': max_days = atoi(optarg); break;
            case 'D': debug_mode = 1; break;
            case 'v':
                fprintf(stderr, "%s v%s\n", argv[0], VERSION);
                return EXIT_SUCCESS;
            case 'h': print_usage(argv[0]); return EXIT_SUCCESS;
            default: print_usage(argv[0]); return EXIT_FAILURE;
        }
    }

    if (geteuid() != 0) {
        fprintf(stderr, "Error: This daemon must be run as root.\n");
        return EXIT_FAILURE;
    }

    fprintf(stderr, "Starting daemon:\nCheck interval = %d min, max uptime = %d days\n", interval_minutes, max_days);
    
    if (!debug_mode) {
        if (argc == 1) {
            fprintf(stderr, "Run `%s -h` for help.\n", argv[0]);
        }
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

    return EXIT_SUCCESS;
}
