#ifdef __sun
#include <time.h>
#else
#define HAVE_TIMEGM
#define HAVE_TM_TM_GMT_OFF
#endif

#ifdef WIN32
#define timegm _mkgmtime
#define HAVE__ISATTY
#else
#define HAVE_MEMMEM
#define HAVE_MKSTEMP
#define HAVE_STRPTIME
#define HAVE_GMTIME_R
#endif

#define HAVE_ALLOCA
#define HAVE_ISATTY
#define HAVE_STRFTIME
#define HAVE_GMTIME
#define HAVE_GETTIMEOFDAY
#define HAVE_ACOS
#define HAVE_ACOSH
#define HAVE_ASIN
#define HAVE_ASINH
#define HAVE_ATAN
#define HAVE_ATANH
#define HAVE_CBRT
#define HAVE_COS
#define HAVE_COSH
#define HAVE_EXP2
#define HAVE_EXP
#define HAVE_FLOOR
#define HAVE_J0
#define HAVE_J1
#define HAVE_LOG10
#define HAVE_LOG2
#define HAVE_LOG
#define HAVE_SIN
#define HAVE_SINH
#define HAVE_SQRT
#define HAVE_TAN
#define HAVE_TANH
#define HAVE_TGAMMA
#define HAVE_Y0
#define HAVE_Y1
#define HAVE_POW
#define HAVE_ATAN2
#define HAVE_HYPOT
#define HAVE_REMAINDER
#define HAVE___THREAD

#include <Rconfig.h>
#ifdef WORDS_BIGENDIAN
  #define IEEE_MC68k
#else
  #define IEEE_8087
#endif
