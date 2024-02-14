// import PersonIcon from "@mui/icons-material/Person";
import CallIcon from "@mui/icons-material/Call";
import ChatHeader from "./ChatHeader";
import ChatIcon from "./ChatHeader";
import ChatStuff from "../../ChatStuff";
import MessageBox from "screens/Chat/MessageBox";
import MessageInput, {
  Recipient,
  Loading,
  Text,
  BlurryLoader,
  InfiniteList,
} from "./MessageInput";
import {
  Center,
  Loading,
  Text,
  BlurryLoader,
  InfiniteList,
  FiniteList,
} from "components";
import { Chat as ChatService } from "services";
import { LoadingButton } from "@mui/lab";
import { Stack, Divider } from "@mui/material";
import { toast } from "react-toastify";
import { unit, Some, isImage, Maybe, toMaybe, isPdf } from "helpers";
import { useQuery } from "@tanstack/react-query";
import { useSearchParams } from "react-router-dom";
import { useState, useMemo, useEffect } from "react";

const someVar = "someVar";

function test() {
  console.log("some");
  console.log("some");
  console.log("some");
  console.log("some");
}
