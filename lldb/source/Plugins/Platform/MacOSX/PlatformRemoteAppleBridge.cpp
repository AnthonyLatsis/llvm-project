//===-- PlatformRemoteAppleBridge.cpp -------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// C Includes
// C++ Includes
#include <string>
#include <vector>

// Other libraries and framework includes
// Project includes
#include "PlatformRemoteAppleBridge.h"

#include "lldb/Breakpoint/BreakpointLocation.h"
#include "lldb/Core/Module.h"
#include "lldb/Core/ModuleList.h"
#include "lldb/Core/ModuleSpec.h"
#include "lldb/Core/PluginManager.h"
#include "lldb/Host/Host.h"
#include "lldb/Target/Process.h"
#include "lldb/Target/Target.h"
#include "lldb/Utility/ArchSpec.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/Utility/Log.h"
#include "lldb/Utility/StreamString.h"

using namespace lldb;
using namespace lldb_private;

//------------------------------------------------------------------
/// Default Constructor
//------------------------------------------------------------------
PlatformRemoteAppleBridge::PlatformRemoteAppleBridge()
    : PlatformRemoteDarwinDevice () {}

//------------------------------------------------------------------
// Static Variables
//------------------------------------------------------------------
static uint32_t g_initialize_count = 0;

//------------------------------------------------------------------
// Static Functions
//------------------------------------------------------------------
void PlatformRemoteAppleBridge::Initialize() {
  PlatformDarwin::Initialize();

  if (g_initialize_count++ == 0) {
    PluginManager::RegisterPlugin(PlatformRemoteAppleBridge::GetPluginNameStatic(),
                                  PlatformRemoteAppleBridge::GetDescriptionStatic(),
                                  PlatformRemoteAppleBridge::CreateInstance);
  }
}

void PlatformRemoteAppleBridge::Terminate() {
  if (g_initialize_count > 0) {
    if (--g_initialize_count == 0) {
      PluginManager::UnregisterPlugin(PlatformRemoteAppleBridge::CreateInstance);
    }
  }

  PlatformDarwin::Terminate();
}

PlatformSP PlatformRemoteAppleBridge::CreateInstance(bool force,
                                                 const ArchSpec *arch) {
  Log *log(GetLogIfAllCategoriesSet(LIBLLDB_LOG_PLATFORM));
  if (log) {
    const char *arch_name;
    if (arch && arch->GetArchitectureName())
      arch_name = arch->GetArchitectureName();
    else
      arch_name = "<null>";

    const char *triple_cstr =
        arch ? arch->GetTriple().getTriple().c_str() : "<null>";

    log->Printf("PlatformRemoteAppleBridge::%s(force=%s, arch={%s,%s})",
                __FUNCTION__, force ? "true" : "false", arch_name, triple_cstr);
  }

  bool create = force;
  if (!create && arch && arch->IsValid()) {
    switch (arch->GetMachine()) {
    case llvm::Triple::aarch64: {
      const llvm::Triple &triple = arch->GetTriple();
      llvm::Triple::VendorType vendor = triple.getVendor();
      switch (vendor) {
      case llvm::Triple::Apple:
        create = true;
        break;

#if defined(__APPLE__)
      // Only accept "unknown" for the vendor if the host is Apple and
      // it "unknown" wasn't specified (it was just returned because it
      // was NOT specified)
      case llvm::Triple::UnknownArch:
        create = !arch->TripleVendorWasSpecified();
        break;

#endif
      default:
        break;
      }
      if (create) {
        switch (triple.getOS()) {
        // NEED_BRIDGEOS_TRIPLE case llvm::Triple::BridgeOS: 
          break;

        default:
          create = false;
          break;
        }
      }
    } break;
    default:
      break;
    }
  }

  if (create) {
    if (log)
      log->Printf("PlatformRemoteAppleBridge::%s() creating platform",
                  __FUNCTION__);

    return lldb::PlatformSP(new PlatformRemoteAppleBridge());
  }

  if (log)
    log->Printf("PlatformRemoteAppleBridge::%s() aborting creation of platform",
                __FUNCTION__);

  return lldb::PlatformSP();
}

lldb_private::ConstString PlatformRemoteAppleBridge::GetPluginNameStatic() {
  static ConstString g_name("remote-bridgeos");
  return g_name;
}

const char *PlatformRemoteAppleBridge::GetDescriptionStatic() {
  return "Remote BridgeOS platform plug-in.";
}

bool PlatformRemoteAppleBridge::GetSupportedArchitectureAtIndex(uint32_t idx,
                                                            ArchSpec &arch) {
  ArchSpec system_arch(GetSystemArchitecture());

  const ArchSpec::Core system_core = system_arch.GetCore();
  switch (system_core) {
  default:
    switch (idx) {
    case 0:
      arch.SetTriple("arm64-apple-bridgeos");
      return true;
    default:
      break;
    }
    break;

  case ArchSpec::eCore_arm_arm64:
    switch (idx) {
    case 0:
      arch.SetTriple("arm64-apple-bridgeos");
      return true;
    default:
      break;
    }
    break;
  }
  arch.Clear();
  return false;
}


void PlatformRemoteAppleBridge::GetDeviceSupportDirectoryNames (std::vector<std::string> &dirnames) 
{
    dirnames.clear();
    dirnames.push_back("BridgeOS DeviceSupport");
}

std::string PlatformRemoteAppleBridge::GetPlatformName ()
{
    return "BridgeOS.platform";
}

