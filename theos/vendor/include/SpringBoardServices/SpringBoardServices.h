#include <sys/cdefs.h>

__BEGIN_DECLS

mach_port_t SBSSpringBoardServerPort();

void SBFrontmostApplicationDisplayIdentifier(mach_port_t port, char *result);
void SBGetScreenLockStatus(mach_port_t port, BOOL *lockStatus, BOOL *passcodeEnabled);
void SBSUndimScreen();

bool SBSOpenSensitiveURLAndUnlock(CFURLRef url, char flags);

__END_DECLS
