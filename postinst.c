#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/syslimits.h>
#include <unistd.h>

#define SafeFree(x) do { if (x) free(x); } while(false)
#define SafeFreeNULL(x) do { SafeFree(x); (x) = NULL; } while(false)

int is_there(char *candidate) {
    struct stat fin;

    /* XXX work around access(2) false positives for superuser */
    if (access(candidate, X_OK) == 0 &&
        stat(candidate, &fin) == 0 &&
        S_ISREG(fin.st_mode) &&
        (getuid() != 0 ||
        (fin.st_mode & (S_IXUSR | S_IXGRP | S_IXOTH)) != 0))
        return 1;
    return 0;
}

int main() {
    if (getuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }

    char *p, *path, *point;
    ssize_t pathlen;
    char candidate[PATH_MAX];
    const char *d;

    if ((p = getenv("PATH")) == NULL)
        exit(EXIT_FAILURE);
    pathlen = strlen(p) + 1;
    point = malloc(pathlen);
    if (point == NULL)
        err(EXIT_FAILURE, NULL);

    memcpy(point, p, pathlen);

    path = point;
    while ((d = strsep(&path, ":")) != NULL) {
        if (*d == '\0')
            d = ".";
        if (snprintf(candidate, sizeof(candidate), "%s/%s", d, "resolution") >= (int)sizeof(candidate))
            continue;
        if (is_there(candidate)) {
            chown(candidate, 0, 0);
            chmod(candidate, 06755);
            free(point);
            return 0;
        }
    }

    free(point);
    return -1;
}
