/* $NetBSD: inetdctl.c,v 1.00 2022/07/15 09:41:53 tnn Exp $ */

/*
 * Copyright (c) 2022 Arjun <ccldarjun@icloud.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#include <sys/cdefs.h>
__RCSID("$NetBSD: inetdctl.c,v 1.0 2022/7/12 09:41:53 ccldarjun Exp $");

#include <sys/un.h>
#include <sys/socket.h>

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>

__dead static void status_all(void);
__dead static void usage(void);
static void start(char *);
static void stop(char *);
static void load(char *);
static void unload(char *);
static int inetd_ctrl_open(const char *);

const char *inetd_ctrl_path = "/var/run/inetd.sock";
/*
 * describe what program does
 */
int main(int argc, char *argv[])
{
	int ch;

	setprogname(argv[0]);
	while ((ch = getopt(argc, argv, "a:h")) != -1)
		switch (ch) {
		case 'a':
			status_all();
		case 'h':
			usage();
		}
	argc -= optind;
	argv += optind;

	if (argc != 2)
		usage();
	
	if (strcmp(argv[0], "load") == 0)
		load(argv[1]);
	else if (strcmp(argv[0], "unload") == 0)
		unload(argv[1]);
	else if (strcmp(argv[0], "start") == 0)
		start(argv[1]);
	else if (strcmp(argv[0], "stop") == 0)
		stop(argv[1]);
	else
		usage();
}

static void
load(char *service_name)
{
	printf("loading: %s", service_name);
	int d = inetd_ctrl_open(inetd_ctrl_path);
	printf("%d", d);
}

static void
unload(char *service_name)
{
}

static void
start(char *service_name)
{
}

static void
stop(char *service_name)
{
}

static void
status_all(void)
{
	printf("status lol\n");
	exit (0);
}

static void
usage(void)
{
	const char *progname;

	progname = getprogname();
	fprintf(stderr, "usage: %s\n",
	    progname);
	exit(EXIT_FAILURE);
}

static int inetd_ctrl_open(const char * ctrl_path)
{
	int sock;
	int tries = 0;
	struct sockaddr_un addr, dest;

	sock = socket(AF_UNIX, SOCK_DGRAM, 0);
	if (sock < 0) {
		fprintf(stderr, "socket: %s, errno: %d", strerror(errno), errno);
		return sock;
	}

	memset(&addr, 0, sizeof(addr));
	addr.sun_family = AF_UNIX;
	if (strlen(ctrl_path) >= sizeof(addr.sun_path))
		fprintf(stderr, "ctrl_path too long");
	strcpy(addr.sun_path, ctrl_path);

try_again:
	tries++;
	if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
		fprintf(stderr, "bind: %s, errno: %d\n", strerror(errno), errno);
		if (tries > 2) {
			close(sock);
			printf("too many tries, exiting\n");
			return -1;
		} else
			goto try_again;
	}

	if (connect(sock, (struct sockaddr *) &dest, sizeof(dest)) < 0) {
		fprintf(stderr, "connect: %s, errno: %d\n", strerror(errno), errno);
		close(sock);
		unlink(addr.sun_path);
		return -1;
	}

	return sock;
}

