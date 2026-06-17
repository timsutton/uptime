#ifndef UPTIME_RUBY_4_0_STDCKDINT_COMPAT_H
#define UPTIME_RUBY_4_0_STDCKDINT_COMPAT_H

/*
 * bazel-contrib portable Ruby 4.0.x for Darwin is built with
 * HAVE_STDCKDINT_H, but the macOS 14 CI SDK does not provide <stdckdint.h>.
 * This header exists only to keep native gem builds working on that runner.
 */
#ifndef RBIMPL_STDCKDINT_H
#define RBIMPL_STDCKDINT_H
#define ckd_add(result, lhs, rhs) __builtin_add_overflow((lhs), (rhs), (result))
#define ckd_sub(result, lhs, rhs) __builtin_sub_overflow((lhs), (rhs), (result))
#define ckd_mul(result, lhs, rhs) __builtin_mul_overflow((lhs), (rhs), (result))
#define __STDC_VERSION_STDCKDINT_H__ 202311L
#endif

#endif
