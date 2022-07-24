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

#define CTRL_STATUS	1
#define CTRL_START	2 
#define CTRL_STOP	3 
#define CTRL_LOAD	4 
#define CTRL_UNLOAD 5

__dead static void status_all(void);
__dead static void usage(void);
static void start(char *);
static void stop(char *);
static void load(char *);
static void unload(char *);
static void status(char *);
static int inetd_ctrl_open(const char *);

const char *inetd_ctrl_path = "/var/run/inetd.sock";
int ctrl_sock;

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
	
	if ((ctrl_sock = inetd_ctrl_open(inetd_ctrl_path)) < 0)
		exit(1);

	if (strcmp(argv[0], "load") == 0)
		load(argv[1]);
	else if (strcmp(argv[0], "unload") == 0)
		unload(argv[1]);
	else if (strcmp(argv[0], "start") == 0)
		start(argv[1]);
	else if (strcmp(argv[0], "stop") == 0)
		stop(argv[1]);
	else if (strcmp(argv[0], "status") == 0)
		status(argv[1]);
	else
		usage();
}

static void
status(char *service_name)
{
	char *str;
	asprintf(&str, "%c\n%s\n", (char) CTRL_STATUS, service_name);
	printf("sending %s", str);
	if (send(ctrl_sock, str, strlen(str) + strlen(str + 2), 0) == -1)
		perror("send");
	close(ctrl_sock);
	free(str);
}

static void
load(char *service_name)
{
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
	struct sockaddr_un remote;

	if ((sock = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
		fprintf(stderr, "socket: %s, errno: %d", strerror(errno), errno);
		return sock;
	}

	fprintf(stderr, "trying to connect to %s\n", ctrl_path);

	memset(&remote, 0, sizeof(struct sockaddr_un));
	remote.sun_family = AF_UNIX;
	strcpy(remote.sun_path, ctrl_path);

	if (connect(sock, (struct sockaddr *) &remote, SUN_LEN(&remote)) < 0) {
		fprintf(stderr, "connect: %s, errno: %d\n", strerror(errno), errno);
		close(sock);
		return -1;
	}

	fprintf(stderr, "connected\n");
	return sock;
}

