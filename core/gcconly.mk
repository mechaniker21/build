# Copyright (C) 2014-2015 UBER
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Gcc Optimization
  ifeq ($(ENABLE_GCCONLY),true)
     ifndef LOCAL_IS_HOST_MODULE
       ifeq ($(LOCAL_CLANG),)
          ifneq (1,$(words $(filter $(LOCAL_DISABLE_GCCONLY), $(LOCAL_MODULE))))
             ifdef LOCAL_CONLYFLAGS
               LOCAL_CONLYFLAGS += \
                  $(GCC_ONLY_FLAGS)
               else
               LOCAL_CONLYFLAGS := \
                  $(GCC_ONLY_FLAGS)
               endif
               ifdef LOCAL_CPPFLAGS
               LOCAL_CPPFLAGS += \
                  $(GCC_ONLY_FLAGS)
               else
               LOCAL_CPPFLAGS := \
                  $(GCC_ONLY_FLAGS)
              endif
           endif
         endif
      endif
  endif

  ifeq (arm,$(TARGET_ARCH))
   GCC_ONLY_FLAGS := \
	-fira-loop-pressure \
	-fforce-addr \
	-funsafe-loop-optimizations \
	-funroll-loops \
	-ftree-loop-distribution \
	-fsection-anchors \
	-ftree-loop-im \
	-ftree-loop-ivcanon \
	-ffunction-sections \
	-fgcse-las \
	-fgcse-sm \
	-fweb \
	-ffp-contract=fast \
	-mvectorize-with-neon-quad
     else
     GCC_ONLY := \
	-fira-loop-pressure \
	-fforce-addr \
	-funsafe-loop-optimizations \
	-funroll-loops \
	-ftree-loop-distribution \
	-fsection-anchors \
	-ftree-loop-im \
	-ftree-loop-ivcanon \
	-ffunction-sections \
	-fgcse-las \
	-fgcse-sm \
	-fweb \
	-ffp-contract=fast \
	-mvectorize-with-neon-quad
  endif

  LOCAL_DISABLE_GCCONLY := \
        bluetooth.default \
        $(NO_OPTIMIZATIONS)
